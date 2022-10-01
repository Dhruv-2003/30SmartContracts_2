// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

/// for this contract to accept nft , we need to import a contract that will make this contract an nft holder 
import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/token/ERC721/utils/ERC721Holder.sol";

/// only one nft can be sent for once and contract will hold only one NFT for that time
/// nft can be sold and purchased by others , so then the token holders will be able to burn the tokens they own 
/// then transfer the eth to holders
contract MyToken is ERC20, Ownable, ERC20Permit , ERC721Holder {
    IERC721 public nftCollection ;
    uint256 public tokenId; 
    bool public intialized = false ;
    bool public canReedem = false ;

    uint256 public price ;
    bool public forSale = false ;

    constructor() ERC20("MyToken", "MTK") ERC20Permit("MyToken") {}

    /// intialize a nft to this contract , with the no of tokens we want to mint
    function intialize(address _collection, uint256 _tokenId, uint256 _amount) external onlyOwner{
        // to check 
        require(!intialized ,"Already intialized");

        // intializing the IERC721 Contract 
        nftCollection = IERC721(_collection);

        /// transferring the nft to the smart contract first 
        nftCollection.safeTransferFrom(msg.sender,address(this), _tokenId) ;
        tokenId = _tokenId ;
        intialized = true ;

        /// minting the tokens first for the user 
        _mint(msg.sender ,_amount) ;
    }


    // put the nft for sale , for the amount decided by the user
    function putForSale(uint _price) external onlyOwner {
        price = _price ;
        forSale = true ;
    }

    // to buy the nft , can be called by any body 
    function purchase() external payable {
        // check conditions if nft is for sale or not 
        require(forSale ,"NFT is not for sale");
        require(msg.value >= price ,"Not enough ether sent");

        // transfer the nft to the buyer 
        nftCollection.transferFrom(address(this), msg.sender , tokenId) ;
        forSale = false ;
        canReedem = true ;
    }

    // to reedem the eth for the nft sold and burn the tokens the user owns 
    function reedem(uint256 _amount ) external payable {
        // check conditions 
        require(canReedem , "Can not be reedemed");

        // total ether in the contract , that came from sale of the nft 
        uint256 etherTotal = address(this).balance ;

        // reedem amount in ethers
        uint256 reedemAmount = _amount*etherTotal / totalSupply() ;

        _burn(msg.sender , _amount) ;
        payable(msg.sender).transfer(reedemAmount) ;
    }


}
