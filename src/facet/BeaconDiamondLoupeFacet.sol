// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDiamondLoupe} from "diamond-1-hardhat/interfaces/IDiamondLoupe.sol";

import {DiamondBeaconUtils} from "../util/DiamondBeaconUtils.sol";

/**
 * @notice An implementation of {IDiamondLoupe} that forwards all calls to the
 * Beacon.
 * @dev This implementation is intended to be added on the DiamondBeacon as a
 * facet that is called and used by the proxy as its implementation.
 * When using the original {DiamondLoupe} implementation, it would lookup facets
 * in the within the proxy's storage. However, this is wrong as the proxy itself
 * does not contain the diamond infrastructure, but gets its facets from the
 * Beacon
 */
contract BeaconDiamondLoupeFacet is IDiamondLoupe {
    function _getBeaconLoupe() private view returns (IDiamondLoupe) {
        return IDiamondLoupe(DiamondBeaconUtils.getBeacon());
    }

    function facets() external view virtual override returns (Facet[] memory facets_) {
        return _getBeaconLoupe().facets();
    }

    function facetFunctionSelectors(address _facet)
        external
        view
        virtual
        override
        returns (bytes4[] memory facetFunctionSelectors_)
    {
        return _getBeaconLoupe().facetFunctionSelectors(_facet);
    }

    function facetAddresses() external view virtual override returns (address[] memory facetAddresses_) {
        return _getBeaconLoupe().facetAddresses();
    }

    function facetAddress(bytes4 _functionSelector) external view virtual override returns (address facetAddress_) {
        return _getBeaconLoupe().facetAddress(_functionSelector);
    }
}
