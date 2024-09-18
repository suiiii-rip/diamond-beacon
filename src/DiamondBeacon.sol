// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC165} from "openzeppelin-contracts/interfaces/IERC165.sol";

import {IERC173} from "diamond-1-hardhat/interfaces/IERC173.sol";

import {IDiamond} from "diamond-1-hardhat/interfaces/IDiamond.sol";
import {IDiamondCut} from "diamond-1-hardhat/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "diamond-1-hardhat/interfaces/IDiamondLoupe.sol";

import {DiamondCutFacet} from "diamond-1-hardhat/facets/DiamondCutFacet.sol";
import {OwnershipFacet} from "diamond-1-hardhat/facets/OwnershipFacet.sol";

import {LibDiamond} from "diamond-1-hardhat/libraries/LibDiamond.sol";
import {DiamondArgs} from "diamond-1-hardhat/Diamond.sol";

import {IDiamondBeaconERC165} from "./interface/IDiamondBeaconERC165.sol";
import {DiamondLoupeFacet} from "./facet/DiamondLoupeFacet.sol";

/**
 * @notice A {Beacon} implementation that handles DiamondFacets.
 * @dev This beacon directly implements all Diamond-related behavior and allows {DiamondProxy} contracts to
 *      lookup facets for a given function call.
 *      This contract itself should be proxied to allow upgrades of the implementation. This is naturally given
 *      as it directly incorporates diamond facets.
 *      Uses customized {DiamondLoupeFacet} to override ERC165.
 */
contract DiamondBeacon is IERC165, IDiamondBeaconERC165, OwnershipFacet, DiamondCutFacet, DiamondLoupeFacet {
    constructor(address _owner, IDiamond.FacetCut[] memory _diamondCut) {
        LibDiamond.setContractOwner(_owner);

        // it does not make sense to allow any init function call as the contract should only handle the facets
        LibDiamond.diamondCut(_diamondCut, address(0), "");
    }

    function diamondSupportsInterface(bytes4 interfaceId) external view returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.supportedInterfaces[interfaceId];
    }

    function setDiamondSupportsInterface(bytes4[] calldata interfaceIds, SupportsInterfaceOp op) external {
        // if owner
        LibDiamond.enforceIsContractOwner();

        bool s = false;
        if (op == SupportsInterfaceOp.Add) {
            s = true;
        }

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            ds.supportedInterfaces[interfaceIds[i]] = s;
        }
    }

    function supportsInterface(bytes4 i) external view virtual returns (bool) {
        // these are the interfaces the beacon itself implements,
        // NOT the interfaces the diamond implements
        return i == type(IERC165).interfaceId || i == type(IDiamondCut).interfaceId
            || i == type(IDiamondLoupe).interfaceId || i == type(IERC173).interfaceId;
    }
}
