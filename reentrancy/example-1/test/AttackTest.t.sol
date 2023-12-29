// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Victim} from "src/Victim.sol";
import {Attacker} from "src/Attacker.sol";

contract AttackTest is Test {

    Victim victim;
    Attacker attacker;

    address user1 = address(1);
    address user2 = address(2);
    address user3 = address(3);
    address haker = address(4);

    function setUp() public {
        victim = new Victim();
        attacker = new Attacker(victim);
    }

    function test_reentrancy() public {
        // user1 deposit 1 ether in the victim contract
        hoax(user1, 1 ether);
        victim.deposit{value: 1 ether}();

        // user2 deposit 1 ether in the victim contract
        hoax(user2, 1 ether);
        victim.deposit{value: 1 ether}();

        // user3 deposit 1 ether in the victim contract
        hoax(user3, 1 ether);
        victim.deposit{value: 1 ether}();

        uint256 victimBalanceBefore = address(victim).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console.log("Victim contract balance before attack: ", victimBalanceBefore);
        console.log("Attacker contract balance before attack: ", attackerBalanceBefore);

        // hacker use Attacker contract to steel ether from Victim contract
        hoax(haker, 1 ether);
        attacker.attack{value: 1 ether}();

        uint256 victimBalanceAfter = address(victim).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console.log("Victim contract balance after attack: ", victimBalanceAfter);
        console.log("Attacker contract after before attack: ", attackerBalanceAfter);
    }

}