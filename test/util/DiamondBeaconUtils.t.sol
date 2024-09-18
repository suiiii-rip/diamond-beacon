// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/util/DiamondBeaconUtils.sol";

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

    function doSomething(uint256 strength) public {
        emit Boom(strength);
    }
}

contract Beacon is DiamondLoupeFacet, DiamondCutFacet {
    constructor() {
        LibDiamond.setContractOwner(msg.sender);
    }
}

contract Target {
    function upgradeBeaconToAndCall(address newBeacon, bytes memory data) public payable {
        // just forward
        DiamondBeaconUtils.upgradeBeaconToAndCall(newBeacon, data);
    }

    function getBeacon() public view returns (address) {
        return DiamondBeaconUtils.getBeacon();
    }
}

contract DiamondBeaconUtilsTest is Test {
    Target private t;
    Beacon private beacon;

    function setUp() public {
        Something s = new Something();
        beacon = new Beacon();
        IDiamond.FacetCut[] memory cuts = new IDiamond.FacetCut[](1);
        bytes4[] memory sel = new bytes4[](2);
        sel[0] = Something.getSomething.selector;
        sel[1] = Something.doSomething.selector;
        cuts[0] = IDiamond.FacetCut(address(s), IDiamond.FacetCutAction.Add, sel);
        beacon.diamondCut(cuts, address(0), "");

        t = new Target();
    }

    function testUpgradeBeaconToAndCall() public {
        vm.expectEmit();
        emit DiamondBeaconUtils.BeaconUpgraded(address(beacon));

        t.upgradeBeaconToAndCall(address(beacon), "");

        assertEq(t.getBeacon(), address(beacon));
    }

    function testUpgradeBeaconToAndCall_withCall(uint256 s) public {
        vm.expectEmit();
        emit Boom(s);

        t.upgradeBeaconToAndCall(address(beacon), abi.encodeCall(Something.doSomething, (s)));

        assertEq(t.getBeacon(), address(beacon));
    }

    function testUpgradeBeaconToAndCall_invalidCall() public {
        vm.expectRevert();
        t.upgradeBeaconToAndCall(address(beacon), abi.encodeWithSignature("transfer(uint256)", 10));
    }

    function testUpgradeBeaconToAndCall_invalidBeacon(address b) public {
        assumePayable(b);
        assumeNotPrecompile(b);
        vm.expectRevert();
        t.upgradeBeaconToAndCall(b, "");
    }

    function testUpgradeBeaconToAndCall_nonPayable() public {
        deal(address(this), 1 ether);
        vm.expectRevert();
        t.upgradeBeaconToAndCall{value: 1}(address(beacon), "");
    }
}
