// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC165} from "forge-std/interfaces/IERC165.sol";

import {IERC173} from "diamond-1-hardhat/interfaces/IERC173.sol";

import {IDiamondCut} from "diamond-1-hardhat/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "diamond-1-hardhat/interfaces/IDiamondLoupe.sol";

/**
 * @notice Provides the ERC165 interface for the {DiamondBeacon}
 */
abstract contract ERC165DiamondBeacon is IERC165 {
    function supportsInterface(bytes4 i) external view virtual override returns (bool) {
        // these are the interfaces the beacon itself implements,
        // NOT the interfaces the diamond / proxy implements
        return i == type(IERC165).interfaceId || i == type(IDiamondCut).interfaceId
            || i == type(IDiamondLoupe).interfaceId || i == type(IERC173).interfaceId;
    }
}
