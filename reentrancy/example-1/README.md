# Reentrancy Attack

## Overview

This documentation describes a reentrancy attack on a smart contract. The attack targets the `Victim` contract, which is vulnerable to reentrancy due to its implementation. The attack is orchestrated by the `Attacker` contract, exploiting the vulnerability to drain funds from the `Victim` contract.

## Vulnerable Victim Contract

The `Victim` contract has a deposit and withdraw mechanism. Users can deposit Ether into the contract and subsequently withdraw their balance. The vulnerability arises in the `withdrawBalance` function, where an external call is made before a state change, creating an opportunity for reentrancy.

```solidity
function withdrawBalance() public {
    uint256 balance = userBalance[msg.sender];

    // External call
    (bool success,) = msg.sender.call{value: balance}("");
    if (!success) {
        revert();
    }

    // State change
    userBalance[msg.sender] = 0;
}
```

## Exploiting the Vulnerability

The attacker exploits the reentrancy vulnerability through the `Attacker` contract. The attack is orchestrated in two steps:

1. **Deposit and Trigger Attack:**
   - The attacker deploys the `Attacker` contract, passing the `Victim` contract's address to its constructor.
   - The attacker calls the `attack` function on the `Attacker` contract, which internally calls the `deposit` function on the `Victim` contract and immediately follows with a call to `withdrawBalance`.

2. **Recursive Call and Fund Drain:**
   - The `withdrawBalance` function in the `Victim` contract performs an external call to the attacker's contract.
   - The attacker's contract, upon receiving Ether through the external call, triggers the `receive` function. If the victim's contract balance is sufficient, it recursively calls `withdrawBalance` again, draining additional funds.
   - This recursive process continues until the victim's contract is depleted of funds.

## Test Scenario

The provided test scenario (`AttackTest`) demonstrates the reentrancy attack:

1. Users `user1`, `user2`, and `user3` deposit 1 Ether each into the `Victim` contract.
2. The initial balances of the `Victim` and `Attacker` contracts are logged.
3. The attacker (`haker`) uses the `Attacker` contract to trigger the attack by calling the `attack` function.
4. The final balances of the `Victim` and `Attacker` contracts are logged, showcasing the drained funds.

## Mitigation

To mitigate reentrancy attacks, it is crucial to follow the "checks-effects-interactions" pattern. The `withdrawBalance` function should perform state changes before any external calls. This ensures that the contract's state is updated before interacting with external contracts, preventing reentrancy attacks.

```solidity
function withdrawBalance() public {
    uint256 balance = userBalance[msg.sender];
    require(balance > 0, "Insufficient balance");

    // State change
    userBalance[msg.sender] = 0;

    // External call
    (bool success,) = msg.sender.call{value: balance}("");
    require(success, "Transfer failed");
}
```

By adhering to this pattern, developers can significantly reduce the risk of reentrancy vulnerabilities in their smart contracts.

## Installation 🛠️

1. Clone the repository:
```shell
git clone https://github.com/ionOM/smart-contract-attacks.git
```

2. Move to the example-1 folder:
```shell
cd smart-contract-attacks/reentrancy/example-1
```
3. When you are in the example-1 folder, type in the console:
```shell
forge test -vvv
```