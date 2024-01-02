# Mishandling of Ethereum

The provided Solidity smart contracts demonstrate a vulnerability that can lead an attack on the `Victim` contract. The vulnerability lies in the `withdraw` function of the `Victim` contract.

## `Victim` Contract

The `Victim` contract has a `withdraw` function with the following problematic line:

```solidity
require(address(this).balance == totalDeposits); // bad
```

This line checks whether the contract's current ETH balance is equal to the `totalDeposits` variable. The intention seems to be to ensure that the contract only allows withdrawals when the ETH balance matches the total deposits made. However, this check is flawed and can be exploited.

## Exploitation through `AttackVictim` Contract

The attacker deploys an `AttackVictim` contract, initialized with the `Victim` contract as the target. The `AttackVictim` contract contains an `attack` function that triggers a `selfdestruct` to the target `Victim` contract, effectively sending all the funds to the `Victim` contract.

```solidity
function attack() external payable {
    selfdestruct(payable(address(target)));
}
```

## Attack Process

1. **User Deposits to Victim:**
   - An external user initiates a deposit of 1 Ether to the `Victim` contract using the `hoax` function.
   - The `deposit` function of the `Victim` contract is called with 1 Ether.

2. **Attacker Triggers `selfdestruct`:**
   - The test script deploys the `AttackVictim` contract, initialized with the `Victim` contract as the target.
   - The `attack` function is called, triggering a `selfdestruct` to the `Victim` contract, sending all funds to it.

3. **Victim Contract Balance Mismatch:**
   - After the `selfdestruct` in the `AttackVictim` contract, the `Victim` contract's ETH balance becomes greater than the `totalDeposits`.

4. **User Attempt to Withdraw:**
   - The user attempts to withdraw their deposit from the `Victim` contract using the `withdraw` function.

5. **Revert due to Vulnerable Check:**
   - The `withdraw` function of the `Victim` contract contains a check (`require`) that expects the contract's balance to be exactly equal to `totalDeposits`.
   - Since the `totalDeposits` is less than the actual balance due to the `selfdestruct`, the check fails, and the transaction reverts.
  
6. **Denial-of-Service (DoS):**
   - The user is unable to withdraw their funds, resulting in a DoS situation where legitimate users are prevented from accessing their deposited funds.

## Mitigation

To address this vulnerability, the `withdraw` function in the `Victim` contract should be modified to use a `>=` check instead of `==`:

```solidity
require(address(this).balance >= totalDeposits); // fixed
```

This change ensures that the contract allows withdrawals as long as the available ETH balance is at least equal to the total deposits made, preventing the DoS attack.

## Installation 🛠️

1. Clone the repository:
```shell
git clone https://github.com/ionOM/smart-contract-attacks.git
```

2. Move to the self-destruct folder:
```shell
cd smart-contract-attacks/mishandling-of-eth/self-destruct
```
3. When you are in the self-destruct folder, type in the console:
```shell
forge test -vvv
```