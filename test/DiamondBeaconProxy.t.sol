// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/DiamondBeaconProxy.sol";

import {IDiamond} from "diamond-1-hardhat/interfaces/IDiamond.sol";
import {DiamondLoupeFacet} from "diamond-1-hardhat/facets/DiamondLoupeFacet.sol";
import {DiamondCutFacet} from "diamond-1-hardhat/facets/DiamondCutFacet.sol";
import {LibDiamond} from "diamond-1-hardhat/libraries/LibDiamond.sol";

import {StorageSlot} from "openzeppelin-contracts/utils/StorageSlot.sol";

event Boom(uint256 strength);

contract Something {
    function getSomething() public pure returns (uint256) {
        return 12345;
    }

    function getSomethingElse() public pure returns (uint256) {
        return getSomething();
    }

    function doSomething(uint256 strength) public {
        emit Boom(strength);
    }

    function doSomethingElse(uint256 strength) public {
        doSomething(strength);
    }
}

contract Beacon is DiamondLoupeFacet, DiamondCutFacet {
    constructor() {
        LibDiamond.setContractOwner(msg.sender);
    }
}

contract DiamondBeaconProxyTest is Test {
    DiamondBeaconProxy private t;
    Beacon private beacon;
    Something private s;

    function setUp() public {
        s = new Something();
        beacon = new Beacon();
        IDiamond.FacetCut[] memory cuts = new IDiamond.FacetCut[](1);
        bytes4[] memory sel = new bytes4[](2);
        sel[0] = Something.getSomething.selector;
        sel[1] = Something.doSomething.selector;
        cuts[0] = IDiamond.FacetCut(address(s), IDiamond.FacetCutAction.Add, sel);
        beacon.diamondCut(cuts, address(0), "");

        t = new DiamondBeaconProxy(address(beacon), "");
    }

    function testTransaction(uint256 v) public {
        vm.expectEmit();
        emit Boom(v);

        Something(address(t)).doSomething(v);
    }

    function testTransaction_fail(uint256 v) public {
        vm.expectRevert();
        Something(address(t)).doSomethingElse(v);
    }

    function testCall() public view {
        uint256 v = Something(address(t)).getSomething();

        assertEq(s.getSomething(), v);
    }

    function testCall_fail() public {
        vm.expectRevert();
        Something(address(t)).getSomethingElse();
    }

    function testConstructInit(uint256 v) public {
        vm.expectEmit();
        emit Boom(v);

        new DiamondBeaconProxy(address(beacon), abi.encodeCall(Something.doSomething, (v)));
    }
}
