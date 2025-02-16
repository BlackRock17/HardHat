// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.25;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";


struct Auction {
    uint256 tokenId;
    address nftAddress;
    uint256 minPrice;
    uint256 startTime;
    uint256 endTime;
    uint256 minBidIncr;
    uint256 timeExtentionWindow;
    uint256 timeExtentionIncr;
    address seller;
    bool nftClaimed;
    bool rewardClaimed;
}

error CannonBeZero();
error InvalidStartTime();
error InvalidEndTime(string argument);
error InsufficientBid();
error NotInBidPeriod();
error NotValidAuction();
error AuctionUnfinished();
error NotClaimer();
error AlreadyClaimed();
error HighestBidder();
error NoWinner();

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
        uint256 timeExtentionWindow,
        uint256 timeExtentionIncr
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
            tokenId: tokenId,
            nftAddress: tokenAddress,
            minPrice: minPrice,
            startTime: startTime,
            endTime: endTime,
            minBidIncr: minBidIncr,
            timeExtentionWindow: timeExtentionWindow,
            timeExtentionIncr: timeExtentionIncr,
            seller: msg.sender,
            nftClaimed: false,
            rewardClaimed: false
        });

        IERC721(tokenAddress).transferFrom(msg.sender, address(this), tokenId);
    }

    function bid(uint256 auctionId) external payable {
        Auction storage auction = auctions[auctionId];

        if (auction.nftAddress == address(0)) {
            revert NotValidAuction();
        }

        if (block.timestamp < auction.startTime || block.timestamp > auction.endTime) {
            revert NotInBidPeriod();
        }

        uint256 newBid = bids[auctionId][msg.sender] + msg.value;

        if (
            newBid < auction.minPrice ||
            (highestBidders[auctionId] != address(0) &&
                newBid < bids[auctionId][highestBidders[auctionId]] + auction.minBidIncr)
        ) {
            revert InsufficientBid();
        }

        if (block.timestamp > auction.endTime - auction.timeExtentionWindow) {
            auction.endTime += auction.timeExtentionIncr;
        }

        bids[auctionId][msg.sender] = newBid;
        highestBidders[auctionId] = msg.sender;
    }

    function claimNFT(uint256 auctionId) external auctionFinished(auctionId) {
        Auction storage auction = auctions[auctionId];

        if (auction.nftClaimed) {
            revert AlreadyClaimed();
        }

        address highestBidder = highestBidders[auctionId];
        if (
            msg.sender != highestBidder &&
            highestBidders[auctionId] != address(0) &&
            msg.sender != auction.seller
        ) {
            revert NotClaimer();
        }

        auction.nftClaimed = true;

        address reciever = msg.sender == highestBidder
            ? highestBidder
            : auction.seller;
        IERC721(auction.nftAddress).safeTransferFrom(
            address(this),
            reciever,
            auction.tokenId
        );
    }

    function claimBid(uint256 auctionId) external {
        uint256 userBid = bids[auctionId][msg.sender];

        if (highestBidders[auctionId] == msg.sender) {
            revert HighestBidder();
        }

        if (bids[auctionId][msg.sender] != 0) {
            bids[auctionId][msg.sender] = 0;
            _transferETH(payable(msg.sender), userBid);
        }
    }

    function claimReward(uint256 auctionId) external auctionFinished(auctionId) {
        uint256 reward = bids[auctionId][highestBidders[auctionId]];

        if (reward == 0) {
            revert NoWinner();
        }

        Auction storage auction = auctions[auctionId];

        if (auction.rewardClaimed) {
            revert AlreadyClaimed();
        }

        auction.rewardClaimed = true;

        _transferETH(payable(msg.sender), reward);
    }

    function _transferETH(address payable to, uint256 amount) private {
        (bool sent, ) = to.call{value: amount}("");

        require(sent, "Failed to send Ether");
    }

    modifier auctionFinished(uint256 auctionId) {
        if (block.timestamp <= auctions[auctionId].endTime) {
            revert AuctionUnfinished();
        }

        _;
    }
}
