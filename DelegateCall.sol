// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// reference from LearnWeb3DAO

contract Calculator {
    uint256 public result;
    address public user;

    /// add function that just adds the 2 given arguement integers
    function add(uint256 a, uint256 b) public returns (uint256) {
        result = a + b;
        user = msg.sender;
        return result;
    }
}

contract delegateCall {
    function addTwoNumbers(
        address calculator,
        uint256 a,
        uint256 b
    ) public returns (uint256) {
        ///  encoding the function to be called along with the arguements to be passed
        /// then delegateCall will automatically other contract with the function defined
        (bool success, bytes memory result) = calculator.delegatecall(
            abi.encodeWithSignature("add(uint256,uint256)", a, b)
        );

        /// any delegate call will return 2 things :
        //  1st call boolean , if it worked
        //  2nd Any call return , in form of abi
        require(success, "The call to calculator contract failed");

        /// result has to be decoded to be able to print it
        return abi.decode(result, (uint256));
    }
}
