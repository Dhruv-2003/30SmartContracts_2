// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "erc721a/contracts/ERC721A.sol";

/// install erc721a from npm with this command :  npm install --save-dev erc721a

contract Azuki is ERC721A {
    string public baseURI;

    constructor(string memory _uri) ERC721A("Azuki", "AZUKI") {
        baseURI = _uri;
    }

    function mint(uint256 quantity) external payable {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(msg.sender, quantity);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}
