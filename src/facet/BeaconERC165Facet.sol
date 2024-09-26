// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "diamond-1-hardhat/libraries/LibDiamond.sol";

import {IERC165} from "forge-std/interfaces/IERC165.sol";

import {IDiamondBeaconERC165Support} from "../interface/IDiamondBeaconERC165Support.sol";
import {DiamondBeaconUtils} from "../util/DiamondBeaconUtils.sol";

/**
 * @notice {IERC165} facet implementation that forwards requests to the beacon.
 *   The beacon has to implement {IDiamondBeaconERC165Support} as opposed to
 *   {IERC165}. Former allows access to the interface/facet config in the
 *   beacon to the diamond proxy instances.
 */
contract BeaconERC165Facet is IERC165 {
    // This implements ERC-165.
    function supportsInterface(bytes4 _interfaceId) external view override returns (bool) {
        return IDiamondBeaconERC165Support(DiamondBeaconUtils.getBeacon()).diamondSupportsInterface(_interfaceId);
    }
}
