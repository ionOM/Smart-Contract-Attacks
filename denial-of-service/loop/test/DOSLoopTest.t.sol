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