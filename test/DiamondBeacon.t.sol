// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/DiamondBeacon.sol";

import {IDiamond} from "diamond-1-hardhat/interfaces/IDiamond.sol";
import {IDiamondCut} from "diamond-1-hardhat/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "diamond-1-hardhat/interfaces/IDiamondLoupe.sol";

import {IERC173} from "diamond-1-hardhat/interfaces/IERC173.sol";

import {IDiamondBeaconERC165Support} from "../src/interface/IDiamondBeaconERC165Support.sol";

event Boom(uint256 strength);

interface SomeInterface {
    function doSomething(uint256 strength) external;
}

contract Something is SomeInterface {
    function doSomething(uint256 strength) public {
        emit Boom(strength);
    }
}

contract DiamondBeaconTest is Test {
    DiamondBeacon private t;
    Something private s;
    address private owner;

    function setUp() public {
        owner = address(123456);

        s = new Something();

        IDiamond.FacetCut[] memory cuts = new IDiamond.FacetCut[](1);
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = Something.doSomething.selector;
        cuts[0] = IDiamond.FacetCut(address(s), IDiamond.FacetCutAction.Add, selectors);

        t = new DiamondBeacon(owner, cuts);
    }

    function testFacetCut() public view {
        assertEq(t.facetAddress(Something.doSomething.selector), address(s));
    }

    function testOwnership(address o) public {
        assumePayable(o);
        assumeNotPrecompile(o);

        t = new DiamondBeacon(o, new IDiamond.FacetCut[](0));

        assertEq(t.owner(), o);
    }
}
