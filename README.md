# English Auction Smart Contract
This repository contains a simple English Auction smart contract written in Solidity. An English auction is a type of auction where bidders openly bid against each other, with each subsequent bid being higher than the previous one. The highest bidder at the end of the auction wins.

## Features
Start Auction: Initialize an auction with a minimum starting bid.
Place Bid: Allow participants to place bids that are higher than the current highest bid.
End Auction: Conclude the auction, transferring the highest bid amount to the seller and the item to the highest bidder.
Withdraw Funds: Allow non-winning bidders to withdraw their bid amounts.

## Usage
**Start the Auction**:
Call the startAuction function with the desired parameters.

**Place Bids**:
Participants can place bids using the placeBid function. Each bid must be higher than the current highest bid.

**End the Auction**:
The auction can be ended by calling the endAuction function, which will transfer the highest bid amount to the seller and the item to the highest bidder.

**Withdraw Funds**:
Non-winning bidders can withdraw their funds by calling the withdraw function