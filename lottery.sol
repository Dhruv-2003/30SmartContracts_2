// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/// Lottery game Contract
/// Start a lottery game
/// Enter the Game by paying down the fee
/// getRandomWinner from an abi encoding formula
/// pick the winner , winner is awarded and the game ends

/// ALERT -block.timestamp is not recommended to use for randomness

import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable {
    uint256 public fee = 0.01 ether;
    address payable[] public players;
    uint256 public lotteryId;
    // from lottery Id to the winner;
    mapping(uint256 => address payable) lotteryWinner;

    enum State {
        Started,
        Completed,
        WinnerPicked,
        Closed
    }

    State public state = State.Closed;

    event GameStarted();
    event playerEntered(address _player, uint256 _fee);
    event winnerPicked(address _winner, uint256 _amountWon);

    function startLottery() public onlyOwner {
        require(state = State.Closed, "Game Can't be started");
        state = State.Started;
        emit GameStarted();
    }

    function enterLottery() public payable {
        require(state = State.Started, "Game not yet startead");
        require(msg.value >= fee, "Invalid value sent");
        players.push(msg.sender);
        emit playerEntered(msg.sender, msg.value);
    }

    function pickWinner() external onlyOwner {
        require(state != State.WinnerPicked, "Winne is already picked");
        uint256 index = getRandomNumber() % players.length;
        address winner = players[index];
        lotteryWinner[lotteryId] = winner;
        uint256 amount = address(this).balance;
        state = State.WinnerPicked;
        emit winnerPicked(winner, amount);
        (bool success, ) = winner.call{value: amount}("");
        require(success);
        players = new address payable[](0);
        lotteryId += 1;
        state = State.Closed;
    }

    function getRandomNumber() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    function getPlayers() public view returns (address[]) {
        return players;
    }

    function getPastWinner(uint256 _id) public view retunrs(address) {
        return lotteryWinner[_id];
    }
}
