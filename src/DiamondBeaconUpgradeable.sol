// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDiamond} from "diamond-1-hardhat/interfaces/IDiamond.sol";

import {DiamondCutFacet} from "diamond-1-hardhat/facets/DiamondCutFacet.sol";
import {OwnershipFacet} from "diamond-1-hardhat/facets/OwnershipFacet.sol";

import {LibDiamond} from "diamond-1-hardhat/libraries/LibDiamond.sol";

import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "openzeppelin-contracts/proxy/utils/Initializable.sol";

import {DiamondBeaconERC165Support} from "./DiamondBeaconERC165Support.sol";
import {ERC165DiamondBeacon} from "./ERC165DiamondBeacon.sol";

import {DiamondLoupeFacet} from "./facet/DiamondLoupeFacet.sol";

/**
 * @notice A {Beacon} implementation that handles DiamondFacets.
 * @dev This beacon directly implements all Diamond-related behavior and allows
 * {DiamondProxy} contracts to lookup facets for a given function call. This
 * contract itself should be proxied to allow upgrades of the implementation.
 * This is naturally given as it directly incorporates diamond facets.
 * Uses customized {DiamondLoupeFacet} to override ERC165.
 */
contract DiamondBeaconUpgradeable is
    UUPSUpgradeable,
    Initializable,
    ERC165DiamondBeacon,
    DiamondBeaconERC165Support,
    OwnershipFacet,
    DiamondCutFacet,
    DiamondLoupeFacet
{
    constructor() {
        _disableInitializers();
    }

    function init(address _owner, IDiamond.FacetCut[] memory _diamondCut) public initializer {
        LibDiamond.setContractOwner(_owner);

        // it does not make sense to allow any init function call as the
        // contract should only handle the facets
        LibDiamond.diamondCut(_diamondCut, address(0), "");
    }

    function _authorizeUpgrade(address) internal virtual override {
        LibDiamond.enforceIsContractOwner();
    }
}
