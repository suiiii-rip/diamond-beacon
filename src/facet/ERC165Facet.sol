// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "diamond-1-hardhat/libraries/LibDiamond.sol";

import {IERC165} from "openzeppelin-contracts/interfaces/IERC165.sol";

contract ERC165Facet is IERC165 {
    // This implements ERC-165.
    function supportsInterface(bytes4 _interfaceId) external view override returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.supportedInterfaces[_interfaceId];
    }

    // TODO add functions to change interfaces
}
