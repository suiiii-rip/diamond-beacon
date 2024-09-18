// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/util/SignatureUtils.sol";

contract SomeContract {
    function doIt() external {}

    function something(uint256, uint8, string memory) external returns (string memory) {}
}

contract SignatureUtilsTest is Test {
    function testGetSignature_withSelector() public pure {
        bytes memory call = abi.encodeWithSelector(SomeContract.doIt.selector);

        assertEq(SomeContract.doIt.selector, SignatureUtils.getSelector(call), "doIt()");

        call = abi.encodeWithSelector(SomeContract.something.selector, 100, uint8(8), "hello world");

        assertEq(SomeContract.something.selector, SignatureUtils.getSelector(call), "something()");
    }

    function testGetSignature_withSignature() public pure {
        bytes memory call = abi.encodeWithSignature("doIt()");

        assertEq(SomeContract.doIt.selector, SignatureUtils.getSelector(call), "doIt()");

        call = abi.encodeWithSignature("something(uint256,uint8,string)", 100, uint8(8), "hello world");

        assertEq(SomeContract.something.selector, SignatureUtils.getSelector(call), "something()");
    }

    function testGetSignature_encodeCall() public pure {
        bytes memory call = abi.encodeCall(SomeContract.doIt, ());

        assertEq(SomeContract.doIt.selector, SignatureUtils.getSelector(call), "doIt()");

        call = abi.encodeCall(SomeContract.something, (100, uint8(8), "hello world"));

        assertEq(SomeContract.something.selector, SignatureUtils.getSelector(call), "something()");
    }
}
