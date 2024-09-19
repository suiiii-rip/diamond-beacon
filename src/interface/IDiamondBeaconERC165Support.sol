// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @notice Access to the ERC165 configuration in the Diamond Beacon.
 *   Proxies use this interface to expose a proper ERC165 interface.
 *  @dev supported interfaces and facet cuts are technically separated. This
 *  means that supported interfaces have to be changed manually and are not
 *  derived from facets as the implementation of an interface can spread across
 *  multiple facets
 */
interface IDiamondBeaconERC165Support {
    /**
     * @notice Checks whether the diamond configuration supports a given interface.
     *   @param interfaceId Id of the interface to check
     *   @return whether or not the interface is supported
     */
    function diamondSupportsInterface(bytes4 interfaceId) external view returns (bool);

    /**
     * @notice Changes the support status of given interfaces
     *   @param interfaceIds Interface Ids to change
     *   @param isSupported new status of all the given interfaceIds
     */
    function setDiamondSupportsInterface(bytes4[] calldata interfaceIds, bool isSupported) external;
}
