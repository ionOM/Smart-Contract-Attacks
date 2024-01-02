// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Victim} from "src/Victim.sol";
import {AttackVictim} from "src/AttackVictim.sol";

contract AttackTest is Test {
    Victim victim;
    AttackVictim attack;

    address user = address(1);

    function setUp() public {
        victim = new Victim();
        attack = new AttackVictim{value: 1 ether}(victim);
    }

    function test_selfdestructAttack() public {
        
        // An user deposit to victim contract
        hoax(user, 1 ether);
        victim.deposit{value: 1 ether}();

        // attack the victim contract
        attack.attack();

        uint256 victimBalanceBefore = address(victim).balance;
        console.log("Victim contract balance before withdraw:" , victimBalanceBefore);

        // user try withdraw
        vm.prank(user);
        vm.expectRevert();
        victim.withdraw();

        uint256 victimBalanceAfter = address(victim).balance;
        console.log("Victim contract balance after withdraw:" , victimBalanceAfter);

    }
}