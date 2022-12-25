// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// TASK
/// Acts as a ETH Wrapper
/// ETH can be deposited and in return ERC20 tokens are minted of an equal value
/// Withdraw ETH when the ERC20 Tokens are sent back
/// WETH holds all the traits of an ERC20 token

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20 {
    event deposit(address indexed account, uint256 _amount);
    event withdrawl(address indexed account, uint256 _amount);

    constructor() ERC20("Wrapped Ether", "WETH", 18) {}

    /// @dev Function to deposit ETH and mint Wrapped ether
    function deposit() external payable {
        _mint(msg.sender, msg.value);
        emit deposit(msg.sender, msg.value);
    }

    /// to withdraw the ether wrapped and burn the tokens
    function withdraw(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Amount is invalid");
        _burn(msg.sender, amount);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdraw not completed");
        emit withdrawl(msg.sender, amount);
    }

    /// @dev Function to receive Ether. msg.data must be empty
    receive() external payable {
        _mint(msg.sender, msg.value);
        emit deposit(msg.sender, msg.value);
    }

    /// @dev Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
