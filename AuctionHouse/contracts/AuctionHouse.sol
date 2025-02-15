// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

struct Auction {
    uint256 minPrice;
    uint256 startTime;
    uint256 endTime;
    uint256 minBidIncr;
    uint256 timeExtentionRule;
    address seller;
}

contract AuctionHouse {
    uint256 private _nextTokenId;

    mapping (uint256 => Auction) public auctions;

    function createAuction(
        uint256 minPrice,
        uint256 startTime,
        uint256 endTime,
        uint256 minBidIncr,
        uint256 timeExtentionRule
    ) external payable {
        uint256 tokenId = _nextTokenId++;
        auctions[tokenId] = Auction({
            minPrice: minPrice,
            startTime: startTime,
            endTime: endTime,
            minBidIncr: minBidIncr,
            timeExtentionRule: timeExtentionRule,
            seller: msg.sender
        });
    }
}
