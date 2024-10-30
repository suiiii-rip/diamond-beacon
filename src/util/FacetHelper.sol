// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDiamond} from "diamond-1-hardhat/interfaces/IDiamond.sol";

/**
 * @dev Contains some helper methods to create {FacetCut} arrays from function
 * signature arrays. It is not intended for actual deployment.
 *
 */
library FacetHelper {
    /**
     * @dev concatenates two {FaceCut} arrays
     * @return a new array a + b
     *
     */
    function concat(IDiamond.FacetCut[] memory a, IDiamond.FacetCut[] memory b)
        internal
        pure
        returns (IDiamond.FacetCut[] memory)
    {
        IDiamond.FacetCut[] memory r = new IDiamond.FacetCut[](a.length + b.length);

        uint256 i = 0;
        for (; i < a.length; i++) {
            r[i] = a[i];
        }

        uint256 j = 0;
        while (j < b.length) {
            r[i++] = b[j++];
        }

        return r;
    }

    function asArray(bytes4 a) internal pure returns (bytes4[] memory) {
        bytes4[] memory arr = new bytes4[](1);
        arr[0] = a;
        return arr;
    }

    function asArray(bytes4 a, bytes4 b) internal pure returns (bytes4[] memory) {
        bytes4[] memory arr = new bytes4[](2);
        arr[0] = a;
        arr[1] = b;
        return arr;
    }

    function asArray(bytes4 a, bytes4 b, bytes4 c) internal pure returns (bytes4[] memory) {
        bytes4[] memory arr = new bytes4[](3);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        return arr;
    }

    function asArray(bytes4 a, bytes4 b, bytes4 c, bytes4 d) internal pure returns (bytes4[] memory) {
        bytes4[] memory arr = new bytes4[](4);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
        return arr;
    }

    function asArray(bytes4 a, bytes4 b, bytes4 c, bytes4 d, bytes4 e) internal pure returns (bytes4[] memory) {
        bytes4[] memory arr = new bytes4[](5);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
        arr[4] = e;
        return arr;
    }

    function asArray(bytes4 a, bytes4 b, bytes4 c, bytes4 d, bytes4 e, bytes4 f)
        internal
        pure
        returns (bytes4[] memory)
    {
        bytes4[] memory arr = new bytes4[](6);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
        arr[4] = e;
        arr[5] = f;
        return arr;
    }

    function asArray(bytes4 a, bytes4 b, bytes4 c, bytes4 d, bytes4 e, bytes4 f, bytes4 g)
        internal
        pure
        returns (bytes4[] memory)
    {
        bytes4[] memory arr = new bytes4[](7);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
        arr[4] = e;
        arr[5] = f;
        arr[6] = g;
        return arr;
    }

    function asArray(bytes4 a, bytes4 b, bytes4 c, bytes4 d, bytes4 e, bytes4 f, bytes4 g, bytes4 h)
        internal
        pure
        returns (bytes4[] memory)
    {
        bytes4[] memory arr = new bytes4[](8);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
        arr[4] = e;
        arr[5] = f;
        arr[6] = g;
        arr[7] = h;
        return arr;
    }

    function asArray(bytes4 a, bytes4 b, bytes4 c, bytes4 d, bytes4 e, bytes4 f, bytes4 g, bytes4 h, bytes4 i)
        internal
        pure
        returns (bytes4[] memory)
    {
        bytes4[] memory arr = new bytes4[](9);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
        arr[4] = e;
        arr[5] = f;
        arr[6] = g;
        arr[7] = h;
        arr[8] = i;
        return arr;
    }

    function asArray(bytes4 a, bytes4 b, bytes4 c, bytes4 d, bytes4 e, bytes4 f, bytes4 g, bytes4 h, bytes4 i, bytes4 j)
        internal
        pure
        returns (bytes4[] memory)
    {
        bytes4[] memory arr = new bytes4[](10);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
        arr[4] = e;
        arr[5] = f;
        arr[6] = g;
        arr[7] = h;
        arr[8] = i;
        arr[9] = j;
        return arr;
    }

    function asAddCut(bytes4[] memory selectors, address target) internal pure returns (IDiamond.FacetCut[] memory) {
        IDiamond.FacetCut memory c = IDiamond.FacetCut(target, IDiamond.FacetCutAction.Add, selectors);

        IDiamond.FacetCut[] memory cuts = new IDiamond.FacetCut[](1);
        cuts[0] = c;
        return cuts;
    }

    function asRemoveCut(bytes4[] memory selectors) internal pure returns (IDiamond.FacetCut[] memory) {
        IDiamond.FacetCut memory c = IDiamond.FacetCut(address(0), IDiamond.FacetCutAction.Remove, selectors);

        IDiamond.FacetCut[] memory cuts = new IDiamond.FacetCut[](1);
        cuts[0] = c;
        return cuts;
    }

    function asReplaceCut(bytes4[] memory selectors, address target)
        internal
        pure
        returns (IDiamond.FacetCut[] memory)
    {
        IDiamond.FacetCut memory c = IDiamond.FacetCut(target, IDiamond.FacetCutAction.Replace, selectors);

        IDiamond.FacetCut[] memory cuts = new IDiamond.FacetCut[](1);
        cuts[0] = c;
        return cuts;
    }
}
