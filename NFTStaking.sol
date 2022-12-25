// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/token/ERC721/utils/ERC721Holder.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/token/ERC721/IERC721.sol";

// After minting the NFT , we need to approve the nft to be able to transfer this nft to other
// then the token contract can transfer the nft while staking and unstaking
// user can later setApproval as false to cancel the approval for the token contract
// we are rewarding a token for staking the NFT in the contract

contract MyToken is ERC20, Ownable, ERC721Holder {
    // struct for the NFT , containing tokenId and when it arrived and other details
    struct NFT {
        address user;
        uint256 start;
        bool staked;
    }

    // reward rate per second to be awarded
    /// 10 tokens per day will be rewarded for the user
    uint256 public rewardRate = (10 * 10**decimals()) / 1 days;

    // mapping of address of the user to the staked NFT
    mapping(uint256 => NFT) stakedNFTs;

    IERC721 public nftCollection;

    constructor(address _nftCollection) ERC20("MyToken", "MTK") {
        nftCollection = IERC721(_nftCollection);
    }

    ///@dev to stake the nft with the tokenId we want
    // Stake
    function stake(uint256 _tokenId) external {
        require(!stakedNFTs[_tokenId].staked, "The NFT is already staked ");
        nftCollection.safeTransferFrom(msg.sender, address(this), _tokenId);
        NFT nft = stakedNFTs[_tokenId];
        nft.user = msg.sender;
        nft.start = block.timestamp;
        nft.staked = true;
    }

    ///@dev  to calculate the rewards earned for particular tokenId and return the rewardAmount
    function rewardsEarned(uint256 _tokenId) public returns (uint256) {
        uint256 _start = stakedNFTs[_tokenId].start;
        uint256 timeElapsed = block.timestamp - _start;
        return timeElapsed * rewardRate;
    }

    ///@dev to unstake the nft with the tokenId and get the nft back ,  also mint the rewarded token to the user
    function unStake(uint256 _tokenId) external {
        require(
            stakedNFTs[_tokenId].user == msg.sender,
            "You are not the owner of NFT"
        );
        require(
            stakedNFTs[_tokenId].start + 7 days >= block.timestamp,
            "Can not unstake now"
        );
        nftCollection.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete stakedNFTs[_tokenID];
        uint256 amount = rewardsEarned(_tokenId);

        _mint(msg.sender, amount);
    }
}
