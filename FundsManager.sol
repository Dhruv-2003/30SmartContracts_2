// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/access/Ownable.sol";

contract FundsManager is Ownable {
    /// @dev events to keep track of ether receive and Withdrawl
    event received(address user, uint256 amount);
    event withdrawal(address user, uint256 amount);

    bool paused;

    modifier onlyWhenNotPaused() {
        require(!paused, "Contract is currently paused");
        _;
    }

    /// @dev check the balance of the contract at any point of time
    /// @return returns balance of contract address (DAO)
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /// @dev withdraw eth to a particular address in case of grants
    function withdrawEthTo(address payable _to, uint256 _amount)
        public
        onlyOwner
        onlyWhenNotPaused
        returns (bool)
    {
        (bool success, ) = _to.call{value: _amount}("");
        emit withdrawal(_to, _amount);
        return success;
    }

    function pauseContract() public onlyOwner {
        paused = !paused;
    }

    /// @dev Function to receive Ether. msg.data must be empty
    receive() external payable {
        emit received(msg.sender, msg.value);
    }

    /// @dev Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
