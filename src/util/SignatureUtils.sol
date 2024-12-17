// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SignatureUtils {
    /**
     * @dev extracts the function selector from an encoded call.
     * The selector is contained in the first 4 bytes of the call data.
     */
    function getSelector(bytes memory data) internal pure returns (bytes4 selector) {
        /* solhint-disable no-inline-assembly */
        assembly {
            // grab the first word after the array length
            selector := mload(add(data, 0x20))
        }
        /* solhint-enable no-inline-assembly */

        // alternative implementation
        // selector = bytes4(data);
    }
}
