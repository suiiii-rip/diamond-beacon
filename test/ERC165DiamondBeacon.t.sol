// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ERC165DiamondBeacon.sol";

contract Target is ERC165DiamondBeacon {

}

contract ERC165DiamondBeaconTest is Test {
    Target private t;

    function setUp() public {

        t = new Target();
    }

    function testSupportsInterface() public view {
        assertTrue(t.supportsInterface(type(IERC173).interfaceId), "IERC173");
        assertTrue(t.supportsInterface(type(IERC165).interfaceId), "IERC165");
        assertTrue(t.supportsInterface(type(IDiamondCut).interfaceId), "IDiamondCut");
        assertTrue(t.supportsInterface(type(IDiamondLoupe).interfaceId), "IDiamondLoupe");
    }
}
