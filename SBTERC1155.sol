// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// ERC1155 contract to be made soulbound token
/// SBTs are tokens which are once minted can not be transferred , i.e. only mint and burn is allowed

contract SBTERC1155 is ERC1155, ERC1155Supply, Ownable {
    // _paused is used to pause the contract in case of an emergency
    bool public _paused;

    using Strings for uint256;
    string _baseTokenURI;

    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract currently paused");
        _;
    }

    constructor(string memory baseURI) ERC1155("MySBT") {
        _baseTokenURI = baseURI;
    }

    /** to set new URI in case of any issues
     */
    function setURI(string memory newuri) public onlyOwner {
        _baseTokenURI = newuri;
    }

    /** @dev override the original uri function to give specific uri for each tokenIDs
     */
    function uri(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        string memory baseURI = _baseTokenURI;
        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(baseURI, _tokenId.toString(), ".json")
                )
                : "";
    }

    /**
     * @dev setPaused makes the contract paused or unpaused
     */
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    /// to mint theNFT
    function mint(
        address user,
        uint256 tokenId,
        uint256 amount
    ) public onlyWhenNotPaused {
        _mint(user, tokenId, amount, "");
    }

    /// burns the NFT , can be called by the user
    function burn(
        address user,
        uint256 tokenId,
        uint256 amount
    ) public onlyWhenNotPaused {
        _burn(user, tokenId, amount);
    }

    /// allows Owner to revoke an NFT from the user , burns the NFT from the account
    function revoke(
        address user,
        uint256 tokenId,
        uint256 amount
    ) public onlyOwner {
        _burn(user, tokenId, amount);
    }

    /// Allows only if the NFT is being minted or burnt , no transfer allowed
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        require(
            to == address(0) || from == address(0),
            "The NFT is non transferrable"
        );
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
