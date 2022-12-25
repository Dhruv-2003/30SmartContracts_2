// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// TASK
// Marketplace to handle manage the listing and purchase of an NFT
// Create a listing and approve the contract to transfer
// Manage and update the listing
// Create bids and manage them
// Direct purchase of NFT

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarketplace {
    struct Listing {
        uint256 price;
        address seller;
        bool bidding;
        uint256 highestBid;
        address highestBidder;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;

    modifier isNFTOwner(address nftAddress, uint256 tokenId) {
        require(
            IERC721(nftAddress).ownerOf(tokenId) == msg.sender,
            "MRKT: Not the owner"
        );
        _;
    }

    modifier isNotListed(address nftAddress, uint256 tokenId) {
        require(
            listings[nftAddress][tokenId].price == 0,
            "MRKT: Already listed"
        );
        _;
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        require(listings[nftAddress][tokenId].price > 0, "MRKT: Not listed");
        _;
    }

    modifier isActiveBid(address nftAddress, uint256 tokenId) {
        require(listings[nftAddress][tokenId].bidding, "Not For bidding");
    }

    modifier isNotActiveBid(address nftAddress, uint256 tokenId) {
        require(!listings[nftAddress][tokenId].bidding, "For bidding");
    }

    event ListingCreated(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        address seller
    );

    event ListingCanceled(address nftAddress, uint256 tokenId, address seller);

    event ListingUpdated(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice,
        address seller
    );

    event ListingPurchased(
        address nftAddress,
        uint256 tokenId,
        address seller,
        address buyer
    );

    event BidPlaced(
        address nftAddress,
        uint256 tokenId,
        address buyer,
        uint256 bidPrice
    );

    event BidEnded(
        address nftAddress,
        uint256 tokenId,
        address buyer,
        uint256 bidPrice
    );

    /// @dev Create the listing for full purchase and get approval to transfer
    function createListing(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    )
        external
        isNotListed(nftAddress, tokenId)
        isNFTOwner(nftAddress, tokenId)
    {
        require(price > 0, "MRKT: Price must be > 0");
        IERC721 nftContract = IERC721(nftAddress);
        require(
            nftContract.isApprovedForAll(msg.sender, address(this)) ||
                nftContract.getApproved(tokenId) == address(this),
            "MRKT: No approval for NFT"
        );
        listings[nftAddress][tokenId] = Listing({
            price: price,
            seller: msg.sender,
            bidding: false,
            highestPrice: 0,
            highestBidder: address(0)
        });

        emit ListingCreated(nftAddress, tokenId, price, msg.sender);
    }

    /// @dev Cancel the listing
    function cancelListing(address nftAddress, uint256 tokenId)
        external
        isListed(nftAddress, tokenId)
        isNFTOwner(nftAddress, tokenId)
    {
        delete listings[nftAddress][tokenId];
        emit ListingCanceled(nftAddress, tokenId, msg.sender);
    }

    /// @dev Update the Listing
    function updateListing(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice
    ) external isListed(nftAddress, tokenId) isNFTOwner(nftAddress, tokenId) {
        require(newPrice > 0, "MRKT: Price must be > 0");
        listings[nftAddress][tokenId].price = newPrice;
        emit ListingUpdated(nftAddress, tokenId, newPrice, msg.sender);
    }

    /// @dev purchase NFT in full
    function purchaseListingFull(address nftAddress, uint256 tokenId)
        external
        payable
        isListed(nftAddress, tokenId)
    {
        Listing memory listing = listings[nftAddress][tokenId];
        require(msg.value == listing.price, "MRKT: Incorrect ETH supplied");

        delete listings[nftAddress][tokenId];

        IERC721(nftAddress).safeTransferFrom(
            listing.seller,
            msg.sender,
            tokenId
        );
        (bool sent, ) = payable(listing.seller).call{value: msg.value}("");
        require(sent, "Failed to transfer eth");

        emit ListingPurchased(nftAddress, tokenId, listing.seller, msg.sender);
    }

    /// @dev Create Listing for bidding
    function createListingBid(
        address nftAddress,
        uint256 tokenId,
        uint256 floorprice
    )
        external
        isNotListed(nftAddress, tokenId)
        isNFTOwner(nftAddress, tokenId)
        isNotActiveBid(nftAddress, tokenId)
    {
        require(price > 0, "MRKT: Price must be > 0");
        IERC721 nftContract = IERC721(nftAddress);
        require(
            nftContract.isApprovedForAll(msg.sender, address(this)) ||
                nftContract.getApproved(tokenId) == address(this),
            "MRKT: No approval for NFT"
        );
        listings[nftAddress][tokenId] = Listing({
            price: price,
            seller: msg.sender,
            bidding: true,
            highestPrice: price,
            highestBidder: address(0)
        });

        emit ListingCreated(nftAddress, tokenId, price, msg.sender);
    }

    /// @dev Place a new bid for NFT listing
    function placeBid(
        address nftAddress,
        uint256 tokenId,
        uint256 bidPrice
    ) external isActiveBid(nftAddress, tokenId) isListed(nftAddress, tokenId) {
        require(
            bidPrice > listings[nftAddress][tokenId].highestBid,
            "Bid price can not be less than floor"
        );
        Listing memory listing = listings[nftAddress][tokenId];

        listing.highestBid = msg.value;
        listing.highestBidder = msg.sender;
        emit BidPlaced(nftAddress, tokenId, msg.sender, msg.value);
    }

    /// @dev  End bidding on the NFT listing
    function endBidding(address nftAddress, uint256 tokenId)
        external
        isActiveBid(nftAddress, tokenId)
        isListed(nftAddress, tokenId)
        isNFTOwner(nftAddress, tokenId)
    {
        Listing memory listing = listings[nftAddress][tokenId];
        listing.bidding = false;
        emit BidEnded(
            nftAddress,
            tokenId,
            listing.highestBidder,
            listing.highestBid
        );
    }

    /// @dev Purchase the NFT listing as a bid
    function purchaseListingBid(address nftAddress, uint256 tokenId)
        external
        payable
        isListed(nftAddress, tokenId)
        isNotActiveBid(nftAddress, tokenId)
    {
        Listing memory listing = listings[nftAddress][tokenId];
        require(
            msg.value == listing.highestBid,
            "MRKT: Incorrect ETH supplied"
        );
        require(msg.sender == listing.highestBidder, "You are not then bidder");

        delete listings[nftAddress][tokenId];

        IERC721(nftAddress).safeTransferFrom(
            listing.seller,
            msg.sender,
            tokenId
        );
        (bool sent, ) = payable(listing.seller).call{value: msg.value}("");
        require(sent, "Failed to transfer eth");

        emit ListingPurchased(nftAddress, tokenId, listing.seller, msg.sender);
    }
}
