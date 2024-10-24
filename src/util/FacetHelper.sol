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
