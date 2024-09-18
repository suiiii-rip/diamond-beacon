// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SignatureUtils {
    function getSelector(bytes memory data) internal pure returns (bytes4 selector) {
        assembly {
            // grab the first word after the array length
            selector := mload(add(data, 0x20))
        }

        // alternative implementation
        // selector = bytes4(data);
    }
}
