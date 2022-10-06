// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/access/Ownable.sol";

// Tasks
// Create a group for splitting the payments
// Then the payment request is created and pay is transferred to the person
// And  every address has to complete the payment request later

contract SplitPay is Ownable {
    address[] public payers;
    uint256 public totalPayers;

    struct PayRequest {
        address payee;
        uint256 totalAmount;
        address[] paid;
    }

    uint256 public totalRequests;

    mapping(uint256 => PayRequest) public payments;

    event Paid(address indexed payee, uint256 amount);
    event PaidForRequest(uint256 _reqId, address payer, uint256 amountPaid);
    event Recieved(address _payer, uint256 _amountAdded);

    constructor(address _payers, uint256 _NoOfPayers) payable {
        payers = _payers;
        totalPayers = _NoOfPayers;
    }

    /// @dev - create and complete the payment request
    function pay(address _payee, uint256 _amount) onlyOwner {
        require(
            _amount <= address(this).balance,
            "Low Balance , please fill up contract first"
        );

        require(_payee != address(0), "Invalid address");

        PayRequest memory _request = payments[totalRequests];
        _request.payee = _payee;
        _request.totalAmount = _amount;

        (bool success, ) = _payee.call{value: _amount}("");
        require(success, "request not completed");

        emit Paid(_payee, _amount);
    }

    function payForRequest(uint256 _reqId) public payable {
        PayRequest memory _request = payments[_reqId];
        uint256 amountPer = (_request.totalAmount) / totalPayers;
        require(msg.value >= amountPer, "Wrong amount sent ");

        _request.payee.push(msg.sender);
        emit PaidForRequest(_reqId, msg.sender, msg.value);
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = owner().call{value: amount}("");
        require(success, "request not completed");
    }

    /// @dev Function to receive Ether. msg.data must be empty
    receive() external payable {
        emit recieved(msg.sender, msg.value);
    }

    /// @dev Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
