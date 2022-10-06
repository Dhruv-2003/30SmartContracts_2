// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// timelock is a kind of contract that delays the function call of another contract by a defined time
contract TimeLock {
    /// time in UNIX format
    /// to read more about it : https://www.unixtimestamp.com/

    // constant keywork assigns a value to the variable at the time of compilation itself , no modifications at runtime
    uint256 public constant duration = 10 * 365 days;

    // immutable variable are less restricted than constant, they can be assigned at the time of deployement i.e. inside the constructor
    //  moreover we can also assign them the value msg call
    // They can't be read during constructor time
    uint256 public immutable end;
    address payable public immutable owner;

    event Recieved(address _payer, uint256 _amountAdded);
    event withdrawl(address _payee, uint256 amount);

    constructor(address _owner) {
        owner = _owner;
        end = block.timestamp + duration;
    }

    /// to deposit any kind of ERC20 token
    function deposit(address_token, uint256 _amount) external {
        IERC20(token).transfer(msg.sender, address(this), _amount);
    }

    /// withdraw tokens , only Allowed after the duration is passed and called only by owner
    function withdraw(address token, uint256 amount) extnernal {
        require(msg.sender == owner, "You are not the owner ");
        require(block.timestamp >= end, "Not Now , too early");
        if (token == address(0)) {
            /// token address 0 refers to the Ethereum token
            (bool success, ) = owner().call{value: amount}("");
            require(success, "request not completed");
        } else {
            IERC20(token).transfer(owner(), amount);
        }
    }

    /// @dev Function to receive Ether. msg.data must be empty
    receive() external payable {
        emit Recieved(msg.sender, msg.value);
    }

    /// @dev Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
