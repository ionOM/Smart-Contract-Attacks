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

    function setUp() public {
        victim = new Victim();
        attacker = new Attacker(victim);
    }

    function test_mishandling_eth() public {
        // user1 deposit
        hoax(user1, 1 ether);
        victim.enter{value: 1 ether}();

        // user2 deposit
        hoax(user2, 1 ether);
        victim.enter{value: 1 ether}();

        // attack the victim
        attacker.attack{value: 1 ether}();

        uint256 victimBalanceBefore = address(victim).balance;
        console.log("Victim contract balance before sendBack:" , victimBalanceBefore);

        // sendBack() function
        vm.expectRevert();
        victim.sendBack();

        uint256 victimBalanceAfter = address(victim).balance;
        console.log("Victim contract balance after sendBack:" , victimBalanceAfter);
    }
}