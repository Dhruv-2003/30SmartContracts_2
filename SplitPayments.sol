// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/access/Ownable.sol";

// Tasks
// contract created for a pair of address
// Any payment recieved is automatically equally split and paid to the user

contract SplitPay is Ownable {
    address[] public immutable owners;
    uint256 public noOfOwner;

    event payRecieved(address indexed payer, uint256 amount);
    event withdrawl(address indexed payee, uint256 amount);

    constructor(address[] _owners, uint256 _nuOfOwner) {
        owners = _owners;
        noOfOwner = _nuOfOwner;
    }

    function withdraw() external {
        uint256 amount = address(this).balance;
        uint256 amountPer = amount / noOfOwner;
        for (uint256 i = 0; i < noOfOwner; i++) {
            address _to = owners[i];
            (bool success, ) = _to.call{value: amountPer}("");
            require(success, "request not completed");
            emit withdrawl(_to, amountPer);
        }
    }

    /// @dev Function to receive Ether. msg.data must be empty
    receive() external payable {
        uint256 amount = msg.value;
        uint256 amountPer = amount / noOfOwner;
        for (uint256 i = 0; i < noOfOwner; i++) {
            address _to = owners[i];
            (bool success, ) = _to.call{value: amountPer}("");
            require(success, "request not completed");
            emit withdrawl(_to, amountPer);
        }
        emit payRecieved(msg.sender, msg.value);
    }

    /// @dev Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
