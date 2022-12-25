// SPDX-License-Identifier: MIT

// TASK -
// the NFT can only be minted or burnt
// No transfer is allowed for the NFT

// HINT //
// In mint , the NFT is being sent from 0 address to user
// In Burn , the NFT is sent to the 0 address from the user

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SBTERC721 is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    string baseURI;

    event Attest(address indexed to, uint256 indexed tokenId);
    event Revoke(address indexed to, uint256 indexed tokenId);

    constructor(string memory _base, address _contributorContract)
        ERC721("MySBT", "mSBT")
    {
        baseURI = _base;
    }

    // to change the URI at any point of time , the URI is same for all the tokens as we DAO NFT is same for all
    function changeURI(string memory newURI) public onlyOwner {
        baseURI = newURI;
    }

    ///@dev to mint the token ID for the DAO user to join the DAO
    /// can be called by anybody , but it will be called in backend just by the DAO members
    /// NFT will be minted only if the user has contriubuted , the option to mint a NFT will be shown but checked first and then only allowed to mint
    function safeMint(address to) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    /// @dev  The following functions are overrides required by Solidity.
    /// we will allow to call transfer only when the nft is either minted or burnt
    /// So the to and fro address will be the 0 address
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        require(
            to == address(0) || from == address(0),
            "The NFT is non transferrable"
        );
        super._beforeTokenTransfer(from, to, tokenId);
    }

    ///@dev can be called by the owner of token to exit the DAO
    /// Burns the token ID from the users Account
    function burn(uint256 tokenId) external {
        require(
            ownerOf(tokenId) == msg.sender,
            "Only owner of the token can burn it"
        );
        _burn(tokenId);
    }

    ///@dev function to remove someone from the DAO  , called only by the owner
    /// will burn the token ID from the users account
    function revoke(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
    }

    ///@dev after any token transfer , events are emitted
    /// revoke show when the NFT is burnt
    /// attest when NFT is minted
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        if (from == address(0)) {
            //
            emit Attest(to, tokenId);
        } else if (to == address(0)) {
            emit Revoke(to, tokenId);
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
