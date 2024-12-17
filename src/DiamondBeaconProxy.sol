// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DiamondBeaconUtils} from "./util/DiamondBeaconUtils.sol";

import {Proxy} from "openzeppelin-contracts/proxy/Proxy.sol";
import {FunctionNotFound} from "diamond-1-hardhat/Diamond.sol";
import {IDiamondLoupe} from "diamond-1-hardhat/interfaces/IDiamondLoupe.sol";

/**
 * @dev This contract implements a proxy that gets the implementation address
 * of a facet for each call from an {IDiamondLoupe}, specifically a
 * {DiamondBeacon}.
 *
 * The implementation is based on OpenZeppelin's {BeaconProxy}
 *
 * The beacon address can only be set once during construction, and cannot be
 * changed afterwards. It is stored in an immutable variable to avoid
 * unnecessary storage reads, and also in the beacon storage slot specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] so that it can be accessed
 * externally.
 *
 * CAUTION: Since the beacon address can never be changed, you must ensure that
 * you either control the beacon, or trust the beacon to not upgrade the
 * implementation maliciously.
 *
 * IMPORTANT: Do not use the implementation logic to modify the beacon storage
 * slot. Doing so would leave the proxy in an inconsistent state where the
 * beacon storage slot does not match the beacon address.
 */
contract DiamondBeaconProxy is Proxy {
    // An immutable address for the beacon to avoid unnecessary SLOADs before
    // each delegate call.
    // solhint-disable-next-line immutable-vars-naming
    address private immutable _beacon;

    /**
     * @dev Initializes the proxy with `beacon`.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the
     * implementation returned by the beacon. This will typically be an encoded
     * function call, and allows initializing the storage of the proxy like a
     * Solidity constructor.
     *
     * Requirements:
     *
     * - `beacon` must be a contract with the interface {IDiamondLoupe}.
     * - If `data` is empty, `msg.value` must be zero.
     */
    constructor(address beacon, bytes memory data) payable {
        DiamondBeaconUtils.upgradeBeaconToAndCall(beacon, data);
        // zero check implicity handled
        // slither-disable-next-line missing-zero-check
        _beacon = beacon;
    }

    /**
     *  @notice Gets the facet that supports the given selector.
     *  @dev If no facet is found return address(0).
     *  @param _functionSelector The function selector.
     *  @return The facet address.
     */
    function _implementation(bytes4 _functionSelector) internal view virtual returns (address) {
        return IDiamondLoupe(_getBeacon()).facetAddress(_functionSelector);
    }

    /**
     * @dev Returns the beacon.
     */
    function _getBeacon() internal view virtual returns (address) {
        return _beacon;
    }

    /**
     * @dev Delegates the current call to the address returned by
     * `_implementation(_functionSelector)`.
     *
     * This function does not return to its internal call site, it will return
     * directly to the external caller.
     */
    function _fallback() internal virtual override {
        address facet = _implementation(msg.sig);

        if (facet == address(0)) {
            revert FunctionNotFound(msg.sig);
        }

        _delegate(facet);
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by
     * `_implementation()`. Will run if no other function in the contract
     * matches the call data.
     */
    fallback() external payable virtual override {
        _fallback();
    }

    // slither-disable-start dead-code
    /**
     * @dev this implementation is not used and should be dropped by the compiler
     *
     * it has to be overriden tho.
     */
    // solhint-disable-next-line no-empty-blocks
    function _implementation() internal view virtual override returns (address) {}
    // slither-disable-end dead-code
}
