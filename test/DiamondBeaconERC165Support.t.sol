// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/DiamondBeaconERC165Support.sol";

import {IDiamond} from "diamond-1-hardhat/interfaces/IDiamond.sol";
import {IDiamondCut} from "diamond-1-hardhat/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "diamond-1-hardhat/interfaces/IDiamondLoupe.sol";
import {LibDiamond} from "diamond-1-hardhat/libraries/LibDiamond.sol";

import {IERC173} from "diamond-1-hardhat/interfaces/IERC173.sol";

import {IDiamondBeaconERC165Support} from "../src/interface/IDiamondBeaconERC165Support.sol";

contract Target is DiamondBeaconERC165Support {
    constructor(address _owner, IDiamond.FacetCut[] memory _diamondCut) {
        LibDiamond.setContractOwner(_owner);

        // it does not make sense to allow any init function call as the contract should only handle the facets
        LibDiamond.diamondCut(_diamondCut, address(0), "");
    }
}

interface SomeInterface {
    function doSomething(uint256) external;
}

contract DiamondBeaconERC165SupportTest is Test {
    Target private t;

    address private owner;

    function setUp() public {
        owner = address(123456);

        IDiamond.FacetCut[] memory cuts = new IDiamond.FacetCut[](0);

        t = new Target(owner, cuts);
    }

    function testSetDiamondSupportsInterface() public {
        bytes4 id = type(SomeInterface).interfaceId;
        assertFalse(t.diamondSupportsInterface(id));

        bytes4[] memory interfaceIds = new bytes4[](1);
        interfaceIds[0] = id;

        vm.prank(owner);
        t.setDiamondSupportsInterface(interfaceIds, true);

        assertTrue(t.diamondSupportsInterface(id));

        vm.prank(owner);
        t.setDiamondSupportsInterface(interfaceIds, false);
        assertFalse(t.diamondSupportsInterface(id));
    }

    function testSetDiamondSupportsInterface_fuzz(bytes4[] memory interfaceIds) public {
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            assertFalse(t.diamondSupportsInterface(interfaceIds[i]));
        }

        vm.prank(owner);
        t.setDiamondSupportsInterface(interfaceIds, true);

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            assertTrue(t.diamondSupportsInterface(interfaceIds[i]));
        }

        vm.prank(owner);
        t.setDiamondSupportsInterface(interfaceIds, false);

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            assertFalse(t.diamondSupportsInterface(interfaceIds[i]));
        }
    }

    function testSetDiamondSupportsInterface_notOwner(address user, bytes4 id) public {
        vm.assume(user != owner);
        assertFalse(t.diamondSupportsInterface(id));

        bytes4[] memory interfaceIds = new bytes4[](1);
        interfaceIds[0] = id;

        vm.startPrank(user);
        vm.expectRevert();
        t.setDiamondSupportsInterface(interfaceIds, true);
    }
}
