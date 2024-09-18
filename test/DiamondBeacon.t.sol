// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/DiamondBeacon.sol";

import {IDiamond} from "diamond-1-hardhat/interfaces/IDiamond.sol";
import {IDiamondCut} from "diamond-1-hardhat/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "diamond-1-hardhat/interfaces/IDiamondLoupe.sol";

import {IERC165} from "openzeppelin-contracts/interfaces/IERC165.sol";

import {IERC173} from "diamond-1-hardhat/interfaces/IERC173.sol";

import {IDiamondBeaconERC165} from "../src/interface/IDiamondBeaconERC165.sol";

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

    address private owner;

    function setUp() public {
        owner = address(123456);

        Something _s = new Something();

        IDiamond.FacetCut[] memory cuts = new IDiamond.FacetCut[](1);
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = Something.doSomething.selector;
        cuts[0] = IDiamond.FacetCut(address(_s), IDiamond.FacetCutAction.Add, selectors);

        t = new DiamondBeacon(owner, cuts);
    }

    function testSetDiamondSupportsInterface() public {
        bytes4 id = type(SomeInterface).interfaceId;
        assertFalse(t.diamondSupportsInterface(id));

        bytes4[] memory interfaceIds = new bytes4[](1);
        interfaceIds[0] = id;

        vm.prank(owner);
        t.setDiamondSupportsInterface(interfaceIds, IDiamondBeaconERC165.SupportsInterfaceOp.Add);

        assertTrue(t.diamondSupportsInterface(id));

        vm.prank(owner);
        t.setDiamondSupportsInterface(interfaceIds, IDiamondBeaconERC165.SupportsInterfaceOp.Remove);
        assertFalse(t.diamondSupportsInterface(id));
    }

    function testSetDiamondSupportsInterface_fuzz(bytes4[] memory interfaceIds) public {
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            assertFalse(t.diamondSupportsInterface(interfaceIds[i]));
        }

        vm.prank(owner);
        t.setDiamondSupportsInterface(interfaceIds, IDiamondBeaconERC165.SupportsInterfaceOp.Add);

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            assertTrue(t.diamondSupportsInterface(interfaceIds[i]));
        }

        vm.prank(owner);
        t.setDiamondSupportsInterface(interfaceIds, IDiamondBeaconERC165.SupportsInterfaceOp.Remove);

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            assertFalse(t.diamondSupportsInterface(interfaceIds[i]));
        }
    }

    function testSetDiamondSupportsInterface_notOwner(address user, bytes4 id) public {
        assertFalse(t.diamondSupportsInterface(id));

        bytes4[] memory interfaceIds = new bytes4[](1);
        interfaceIds[0] = id;

        vm.startPrank(user);
        vm.expectRevert();
        t.setDiamondSupportsInterface(interfaceIds, IDiamondBeaconERC165.SupportsInterfaceOp.Add);
    }

    function testSupportsInterface() public view {
        assertTrue(t.supportsInterface(type(IERC173).interfaceId), "IERC173");
        assertTrue(t.supportsInterface(type(IERC165).interfaceId), "IERC165");
        assertTrue(t.supportsInterface(type(IDiamondCut).interfaceId), "IDiamondCut");
        assertTrue(t.supportsInterface(type(IDiamondLoupe).interfaceId), "IDiamondLoupe");
    }
}
