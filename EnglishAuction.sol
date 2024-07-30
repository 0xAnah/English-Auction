// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract EnglishAuction {
    // emitted when the auction starts
    event Start(uint256 indexed time);
    // eimtted when an account makes a bid
    event Bid(address indexed account, uint indexed amount);
    // emitted when a user makes a withdrawal
    event Withdraw(address account, uint256 amount);
    // emitted when auction ends
    event End(address account, uint256 amount);

    // The nft contract address
    IERC721 public immutable nft;
    // The particular token to be auctioned
    uint256 public immutable nftTokenId;

    // address of the seller
    address payable public immutable seller;
    // starting time
    uint32 public startAt;
    // ending time
    uint256 public endsAt;

    // The current highest bidder
    address public highestBidder;
    // The current highest bid made
    uint256 public highestBid;
    // has the contract stated accepting bis
    bool public started;
    // has the contract stop accepting bids
    bool public ended;

    // bidders and their total bids
    mapping(address bidder => uint256 bid) public bids;

    constructor (
        address _nft,
        uint256 _nftTokenId,
        uint256 _startingBid
    ) {

        nft = IERC721(_nft);
        nftTokenId = _nftTokenId;
        seller = payable(msg.sender);
        highestBid = _startingBid;
        
        endsAt = uint32(block.timestamp + 7 days);
    }

    function start() public {
        // only seller can start auction
        require(msg.sender == seller, "Only seller can start auction");
        // ensure auction has not started yet
        require(!started, "Auction has already started");
        
        started = true;
        startAt = uint32(block.timestamp);
        endsAt = uint32(block.timestamp + 7 days);

        // make this contract owner of token
        nft.safeTransferFrom(seller, address(this), nftTokenId);

        emit Start(block.timestamp);

    }

    function bid() public payable {
        // ensure that bid has started
        require(started, "bid not started yet");
        // ensure that bidding hasn't ended yet
        require(block.timestamp < endsAt, "Bidding ended");
        // ensure sender's bid is higher than the current highest bid
        require(msg.value > highestBid, "Your bid is less than highest bid");

        // when there is a new hingest bidder keep note of the previous highest
        // bidder and his bid
        if(highestBidder != address(0)){
            bids[highestBidder] += highestBid;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;

        emit Bid(msg.sender, msg.value);
    }

    function withdraw() public {
        // ensure highest bidder cannot withdraw his bid
        require(msg.sender != highestBidder, "Highest bidder cannot withdraw his bid");
        uint256 bal = bids[msg.sender];
        bids[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: bal}("");

        require(success, "Transfer failed");
    }

    function end() public {
        // ensure auction has not ended yet
        require(block.timestamp > endsAt, "Auction not ended yet");
        require(!ended);

        // in a scenario where nobody bids the nft ensure the nft is not tranfered to
        // address zero rather it is transfered back to the seller
        if(highestBidder != address(0)) {
            // check if the highest bidder has other bids that were previously marked as highestbid
            uint256 highestBidderTotalBids = bids[highestBidder];
            bids[highestBidder] = 0;
            uint256 _highestBid = highestBid;
            highestBid = 0;
            if(highestBidderTotalBids > highestBid) {
                // if the total of the highest bidder previoulsy marked bid is greater than the 
                // current highestbid transfer the difference back to the highest bidder
                (bool success,) = highestBidder.call{value: highestBidderTotalBids - _highestBid}("");
                require(success, "Transfer Failed");
            }
            else {
                // if the total of the highest bidder previoulsy marked bid is less than the 
                // current highestbid transfer the difference back to the highest bidder
                (bool success,) = highestBidder.call{value: _highestBid - highestBidderTotalBids}("");
                require(success, "Transfer Failed");
            }
            
            // Transfer nft to the highest bidder
            nft.safeTransferFrom(address(this), highestBidder, nftTokenId);
            // Transfer eth to the 
            (bool success,) = seller.call{value: _highestBid}("");
            require(success, "Transfer Failed");
        }else {
            // This means the nft had no bids
            nft.safeTransferFrom(address(this), seller, nftTokenId);

        }

    }

}