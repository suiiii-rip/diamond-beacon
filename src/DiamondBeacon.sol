// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDiamond} from "diamond-1-hardhat/interfaces/IDiamond.sol";

import {DiamondCutFacet} from "diamond-1-hardhat/facets/DiamondCutFacet.sol";
import {OwnershipFacet} from "diamond-1-hardhat/facets/OwnershipFacet.sol";

import {LibDiamond} from "diamond-1-hardhat/libraries/LibDiamond.sol";

import {DiamondBeaconERC165Support} from "./DiamondBeaconERC165Support.sol";
import {ERC165DiamondBeacon} from "./ERC165DiamondBeacon.sol";

import {DiamondLoupeFacet} from "./facet/DiamondLoupeFacet.sol";

/**
 * @notice A {Beacon} implementation that handles DiamondFacets.
 * @dev This beacon directly implements all Diamond-related behavior and allows {DiamondProxy} contracts to
 *      lookup facets for a given function call.
 *      Uses customized {DiamondLoupeFacet} to override ERC165 behavior.
 */
contract DiamondBeacon is
    ERC165DiamondBeacon,
    DiamondBeaconERC165Support,
    OwnershipFacet,
    DiamondCutFacet,
    DiamondLoupeFacet
{
    constructor(address _owner, IDiamond.FacetCut[] memory _diamondCut) {
        LibDiamond.setContractOwner(_owner);

        // it does not make sense to allow any init function call as the contract should only handle the facets
        // and does not have any other state variables
        LibDiamond.diamondCut(_diamondCut, address(0), "");
    }
}
