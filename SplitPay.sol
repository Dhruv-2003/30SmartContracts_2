// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/access/Ownable.sol";

// Tasks
// Create a group for splitting the amount
// Add money in this contract
// Pay with the help of this contract

contract SplitPay is Ownable {
    address[] public owners;

    constructor(address[] _owners) {
        owners = _owners;
    }
}
