// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//-seller deploy the contracts and send in the funds
//-agreement and send in funds
//-item shipped
//-Buyer confirms the recieve
//-Funds released to the seller and contract is destroyed

import "@openzeppelin/contracts/access/Ownable.sol";

contract safeRemotePurchase is Ownable {
    /// initial fixed variables
    /// payable makes the addresses payable , to be able to pay some amount
    address payable public seller;
    address payable public buyer;
    uint256 public value;

    /// to maintain the state of the contract
    enum State {
        Created,
        Locked,
        Released,
        Inactive
    }

    State public state;

    /// events to keep track of contract
    event AgreementCreated(address _buyer, address _seller, uint256 _value);
    event AgreementComplete(address _buyer, address _seller, uint256 _value);
    event AgreementAborted(address _buyer, address _seller);

    constructor(address _buyer, uint256 _value) payable {
        require(_buyer != address(0), "Address not valid ");

        seller = payable(msg.sender);
        buyer = payable(_buyer);
        value = _value;
        require(msg.value == (2 * _value), "Incorrect amount locked");
        state = State.Created;
    }

    /// intialising the purchase , called only by the buyer
    /// state changes to locked
    function purchase() external payable {
        require(msg.sender == buyer, "You are not buyer");
        require(msg.value == (2 * value), "Invalid amount send");
        require(state == State.Created, "Invalid State call");
        state = State.Locked;
        emit AgreementCreated(buyer, seller, value);
    }

    /// complete the purchase and releasing the funds
    /// getting the extra stake paid back
    function completePurchase() external {
        require(msg.sender == buyer, "You are not buyer");
        state = State.Released;
        (bool success, ) = buyer.call{value: value}("");
        require(success, "Tx not completed");
        emit AgreementComplete(buyer, seller, value);
    }

    /// withdraw funds in the balance after the funds are released
    function withdraw() external {
        require(state == State.Released, "Withdrawl not allowed");
        uint256 amount = address(this).balance;
        (bool success, ) = seller.call{value: amount}("");
        require(success, "Tx not completed");
        state = State.Inactive;
    }

    /// abort the agreement ,called only be the seller
    /// both buyer and seller are returned thier intial stakes
    function abortAgreement() external onlyOwner {
        uint256 amount = value * 2;
        (bool success, ) = seller.call{value: amount}("");
        require(success, "Tx not completed");
        (bool success, ) = buyer.call{value: amount}("");
        require(success, "Tx not completed");
        state = State.Inactive;
        emit AgreementAborted(buyer, seller);
    }
}
