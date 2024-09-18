// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @notice Access to the ERC165 configuration in the Diamond Beacon.
 *   Proxies use this interface to expose a proper ERC165 interface.
 */
interface IDiamondBeaconERC165 {
    enum SupportsInterfaceOp {
        Add,
        Remove
    }

    function diamondSupportsInterface(bytes4 interfaceId) external view returns (bool);

    function setDiamondSupportsInterface(bytes4[] calldata interfaceIds, SupportsInterfaceOp op) external;
}
