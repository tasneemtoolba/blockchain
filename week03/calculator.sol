// SPDX-License-Identifier: MIT

pragma solidity >= 0.6.0 <0.9.0;

contract Calculator{

uint public ans;
uint public num1 = 20;
uint public num2 = 5;

    function adding() public {
         ans = num1 + num2;

    }
        function subtracting() public {
        ans = num1 - num2;

    }
        function multiplying() public {
        ans = num1 * num2;
    }
        function dividing() public {
        ans = num1 / num2;
    }

}