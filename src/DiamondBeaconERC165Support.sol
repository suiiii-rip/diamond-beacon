// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC173} from "diamond-1-hardhat/interfaces/IERC173.sol";

import {LibDiamond} from "diamond-1-hardhat/libraries/LibDiamond.sol";

import {IDiamondBeaconERC165Support} from "./interface/IDiamondBeaconERC165Support.sol";

/**
 * @notice Abstract mixin of {IDiamondBeaconERC165Support}
 * @dev Looks up supported interface in the diamond storage in conjunction with
 * a {BeaconERC165Facet} implementation. This provides ERC165 on Proxy instances
 */
abstract contract DiamondBeaconERC165Support is IDiamondBeaconERC165Support {
    function diamondSupportsInterface(bytes4 interfaceId) external view override returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.supportedInterfaces[interfaceId];
    }

    function setDiamondSupportsInterface(bytes4[] calldata interfaceIds, bool isSupported) external override {
        // if owner
        LibDiamond.enforceIsContractOwner();

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            ds.supportedInterfaces[interfaceIds[i]] = isSupported;
        }
    }
}
