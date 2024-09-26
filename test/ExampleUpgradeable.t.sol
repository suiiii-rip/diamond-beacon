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

/**
 * @notice This test acts as an example of how to setup the
 * {DiamondBeaconUpgradeable} and as somewhat integration test
 */
contract ExampleUpgradeableTest is Test {
    SomethingFacet s;

    DiamondBeaconUpgradeable beacon;
    DiamondBeaconProxy proxy;

    address owner;

    function setUp() public {
        // define the beacon owner / admin
        owner = address(12345);

        // deploy some implementation
        s = new SomethingFacet();

        // create the diamond cut
        IDiamond.FacetCut[] memory cuts = new IDiamond.FacetCut[](2);
        {
            bytes4[] memory sel = new bytes4[](2);
            sel[0] = SomethingFacet.getSomething.selector;
            sel[1] = SomethingFacet.doSomething.selector;
            cuts[0] = IDiamond.FacetCut(address(s), IDiamond.FacetCutAction.Add, sel);
        }

        {
            BeaconERC165Facet erc165Facet = new BeaconERC165Facet();
            bytes4[] memory sel = new bytes4[](1);
            sel[0] = BeaconERC165Facet.supportsInterface.selector;
            cuts[1] = IDiamond.FacetCut(address(erc165Facet), IDiamond.FacetCutAction.Add, sel);
        }

        // define the supported interfaces
        bytes4[] memory interfaces = new bytes4[](1);
        interfaces[0] = type(ISomething).interfaceId;

        // deploy the beacon implementation
        address beaconImpl = address(new DiamondBeaconUpgradeable());

        // define the init call
        bytes memory initCall = abi.encodeCall(DiamondBeaconUpgradeable.init, (owner, cuts));

        // deploy the proxy pointing to the upgradeable beacon implementation
        vm.startPrank(owner);
        beacon = DiamondBeaconUpgradeable(address(new ERC1967Proxy(beaconImpl, initCall)));
        beacon.setDiamondSupportsInterface(interfaces, true);
        vm.stopPrank();

        // deploy a user facing proxy that points to the beacon construct
        proxy = new DiamondBeaconProxy(address(beacon), "");
    }

    function testIt(uint256 val) public {
        SomethingFacet ss = SomethingFacet(address(proxy));

        vm.expectEmit();
        emit Boom(val);
        ss.doSomething(val);

        assertEq(ss.getSomething(), val);

        assertTrue(IERC165(address(proxy)).supportsInterface(type(ISomething).interfaceId));
        assertTrue(IERC165(address(beacon)).supportsInterface(type(IERC165).interfaceId));
    }
}

event Boom(uint256 strength);

interface ISomething {
    function doSomething(uint256 _strength) external;
}

contract SomethingFacet is ISomething {
    uint256 private strength;

    function getSomething() public view returns (uint256) {
        return strength;
    }

    function getSomethingElse() public view returns (uint256) {
        return getSomething();
    }

    function doSomething(uint256 _strength) public override {
        strength = _strength;
        emit Boom(strength);
    }

    function doSomethingElse(uint256 _strength) public {
        doSomething(_strength);
    }
}
