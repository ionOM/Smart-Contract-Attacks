// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Auction {
    address public lastBidder;
    uint256 public highestBid;

    function bid() public payable {
        require(msg.value > highestBid, "invalid amount");
        (bool sent, ) = payable(lastBidder).call{value: highestBid}("");
        require(sent, "Failed to send Ether");

       lastBidder = msg.sender;
       highestBid = msg.value;
    }
}