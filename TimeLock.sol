// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20{
    function transfer(address recipient, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);

}

contract Transfer{

    function Transfer 
}

/// timelock is a kind of contract that delays the function call of another contract by a defined time 

contract TimeLock{
    /// time in UNIX format
    /// to read more about it : https://www.unixtimestamp.com/
    uint256 deadline ;

    constructor() {
        

    }    
}