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

contract AuctionHouse {
    uint256 MIN_AUCTION_DURATION = 1 days;
    uint256 MAX_AUCTION_DURATION = 60 days;
    uint256 private _nextAuctionId;

    mapping (uint256 => Auction) public auctions;

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
}
