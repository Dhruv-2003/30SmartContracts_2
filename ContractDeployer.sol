// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Deployer {
    A[] public _deployed;

    function deploy(uint256 _b) public {
        /// contract is deployed with the help of new Keyword
        //  creates the new contract with the constuctor arguement passed in
        // address(_contract) give the address of the new contract

        A _contract = new A(_b, msg.sender);

        /// now the msg.sender will be this contract and not the deploy function caller
        /// we have to pass the value to make him the owner

        _deployed.push(_contract);
    }

    function getDeployed() public view returns (A[] memory) {
        return _deployed;
    }
}

/// Contract to be deployed , can be any type of contract
contract A {
    address public owner;
    uint256 public b;

    constructor(uint256 _b, address _owner) {
        owner = _owner;
        b = _b;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }
}
