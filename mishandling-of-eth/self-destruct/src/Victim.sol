// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Victim {
    uint256 public totalDeposits;
    mapping(address => uint256) public deposits;

    function deposit() external payable {
        deposits[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }
}