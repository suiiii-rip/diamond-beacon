// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import {IERC165} from "forge-std/interfaces/IERC165.sol";

import {DiamondBeaconUpgradeable} from "../src/DiamondBeaconUpgradeable.sol";
import {DiamondBeaconProxy} from "../src/DiamondBeaconProxy.sol";

import {BeaconERC165Facet} from "../src/facet/BeaconERC165Facet.sol";

import {IDiamond} from "diamond-1-hardhat/interfaces/IDiamond.sol";
import {DiamondLoupeFacet} from "diamond-1-hardhat/facets/DiamondLoupeFacet.sol";
import {DiamondCutFacet} from "diamond-1-hardhat/facets/DiamondCutFacet.sol";
import {LibDiamond} from "diamond-1-hardhat/libraries/LibDiamond.sol";

import {StorageSlot} from "openzeppelin-contracts/utils/StorageSlot.sol";

import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DiamondBeaconUpgradeableTest is Test {
    DiamondBeaconUpgradeable beacon;

    address owner;

    function setUp() public {
        owner = address(12345);
        IDiamond.FacetCut[] memory cuts = new IDiamond.FacetCut[](1);

        {
            BeaconERC165Facet erc165Facet = new BeaconERC165Facet();
            bytes4[] memory sel = new bytes4[](1);
            sel[0] = BeaconERC165Facet.supportsInterface.selector;
            cuts[0] = IDiamond.FacetCut(address(erc165Facet), IDiamond.FacetCutAction.Add, sel);
        }

        bytes4[] memory interfaces = new bytes4[](1);
        interfaces[0] = type(ISomething).interfaceId;

        address beaconImpl = address(new DiamondBeaconUpgradeable());

        bytes memory initCall = abi.encodeCall(DiamondBeaconUpgradeable.init, (owner, cuts));

        vm.startPrank(owner);
        beacon = DiamondBeaconUpgradeable(address(new ERC1967Proxy(beaconImpl, initCall)));
        beacon.setDiamondSupportsInterface(interfaces, true);
        vm.stopPrank();
    }

    function testInit() public view {
        assertTrue(beacon.diamondSupportsInterface(type(ISomething).interfaceId));
        assertTrue(beacon.supportsInterface(type(IERC165).interfaceId));
    }

    function testUpgrade() public {
        address otherBeaconImpl = address(new DiamondBeaconUpgradeable());

        vm.prank(owner);
        beacon.upgradeToAndCall(otherBeaconImpl, "");
    }

    function testUpgrade_notOwner(address user) public {
        assumePayable(user);
        vm.assume(user != owner);

        address otherBeaconImpl = address(new DiamondBeaconUpgradeable());

        vm.prank(user);
        vm.expectRevert();
        beacon.upgradeToAndCall(otherBeaconImpl, "");
    }
}

interface ISomething {
    function doSomething(uint256 _strength) external;
}
