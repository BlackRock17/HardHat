// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.25;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";


struct Auction {
    uint256 minPrice;
    uint256 startTime;
    uint256 endTime;
    uint256 minBidIncr;
    uint256 timeExtentionRule;
    address seller;
}

error CannonBeZero();
error InvalidStartTime();
error InvalidEndTime(string argument);
error InsufficientBid();

contract AuctionHouse {
    uint256 MIN_AUCTION_DURATION = 1 days;
    uint256 MAX_AUCTION_DURATION = 60 days;
    uint256 private _nextAuctionId;

    mapping (uint256 => Auction) public auctions;
    mapping (uint256 auctionId => mapping(address bidder => uint256 bid)) public bids;
    mapping (uint256 auctionId => address highestBidder) public highestBidders;

    function createAuction(
        uint256 tokenId,
        address tokenAddress,
        uint256 minPrice,
        uint256 startTime,
        uint256 endTime,
        uint256 minBidIncr,
        uint256 timeExtentionRule
    ) external {
        if (minPrice == 0) {
            revert CannonBeZero();
        }

        if (startTime < block.timestamp) {
            revert InvalidStartTime();
        }

        if (endTime < startTime + MIN_AUCTION_DURATION) {
            revert InvalidEndTime("TOO_LOW");
        }

        if (endTime > startTime + MAX_AUCTION_DURATION) {
            revert InvalidEndTime("TOO_HIGH");
        }

        uint256 auctionId = _nextAuctionId++;
        auctions[auctionId] = Auction({
            minPrice: minPrice,
            startTime: startTime,
            endTime: endTime,
            minBidIncr: minBidIncr,
            timeExtentionRule: timeExtentionRule,
            seller: msg.sender
        });

        IERC721(tokenAddress).transferFrom(msg.sender, address(this), tokenId);
    }

    function bid(uint256 auctionId) external payable {
        Auction memory auction = auctions[auctionId];

        if (
            msg.value < auction.minPrice ||
            (highestBidders[auctionId] != address(0) &&
                msg.value < bids[auctionId][highestBidders[auctionId]] + auction.minBidIncr)
        ) {
            revert InsufficientBid();
        }
    }
}
