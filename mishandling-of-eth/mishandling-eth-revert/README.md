Certainly! Here's a markdown description of how this attack works:

---

# Mishandling of Ethereum

## Overview

The provided Solidity smart contracts demonstrate an attack scenario where an `Attacker` contract manipulates a `Victim` contract to exploit a vulnerability. The attack is orchestrated through a testing contract called `AttackTest`. The vulnerability lies in the mishandling of Ether deposits in the `Victim` contract.

## Contracts

### 1. **Victim Contract (`Victim.sol`)**

The `Victim` contract is a simple pooling contract where users can deposit Ether, and the contract promises to send the deposited amount back to all participants at some point. The vulnerability in this contract is that it doesn't properly track the deposited amounts for each user.

### 2. **Attacker Contract (`Attacker.sol`)**

The `Attacker` contract interacts with the `Victim` contract. It performs an attack by making use of the mishandling of Ether deposits in the `Victim` contract.

### 3. **AttackTest Contract (`AttackTest.sol`)**

The `AttackTest` contract serves as a testing environment to simulate and observe the attack. It deploys instances of the `Victim` and `Attacker` contracts and orchestrates the attack through a test function (`test_mishandling_eth`).

## Attack Steps

1. **Setup**

   - Deploy instances of the `Victim` and `Attacker` contracts.
   - Initialize `Victim` and `Attacker` instances in the `AttackTest` contract.

2. **Deposit Ether**

   - Simulate two users (`user1` and `user2`) making deposits to the `Victim` contract.
   - Users call the `hoax` function, emulating a deposit of 1 Ether each.
   - The `enter` function in the `Victim` contract is then called for each user.

3. **Execute the Attack**

   - The `Attacker` contract initiates the attack by calling the `attack` function.
   - This function, in turn, calls the `enter` function of the `Victim` contract, depositing 1 Ether.

4. **Exploit Vulnerability**

   - The `Victim` contract has a vulnerability in the `sendBack` function, where it attempts to refund participants but fails to properly track individual deposits.
   - The `Attacker` contract, having deposited Ether earlier, is included in the list of participants.

5. **Test Function Execution**

   - The `AttackTest` contract executes the `test_mishandling_eth` function.
   - It checks the balance of the `Victim` contract before and after calling the `sendBack` function.

6. **Assertion and Outcome**

   - The test asserts that the `sendBack` function reverts, expecting an exception.
   - The vulnerability causes the `Attacker` to receive Ether back, effectively draining the `Victim` contract.

#### AttackTest.t.sol

```solidity
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
```

## Conclusion

This attack exploits a vulnerability in the mishandling of Ether deposits in the `Victim` contract, allowing the `Attacker` to receive Ether during the refund process. This scenario highlights the importance of proper handling and tracking of funds in smart contracts to prevent potential exploits and vulnerabilities.

## Installation 🛠️

1. Clone the repository:
```shell
git clone https://github.com/ionOM/smart-contract-attacks.git
```

2. Move to the mishandling-eth-revert folder:
```shell
cd smart-contract-attacks/mishandling-of-eth/mishandling-eth-revert
```
3. When you are in the mishandling-eth-revert folder, type in the console:
```shell
forge test -vvv
```