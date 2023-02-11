// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

contract Calculator {
    uint256 public ans;
    uint256 public num1 = 20;
    uint256 public num2 = 5;

    function adding() public {
        assembly {
            sstore(ans.slot,add(num1.slot, num2.slot))

        }
    }

    function subtracting() public {
        assembly {
        
        sstore(ans.slot,sub(num1.slot, num2.slot))
            
        }
    }

    function multiplying() public {
        assembly {
            sstore(ans.slot,mul(num1.slot, num2.slot))

        }
    }

    function dividing() public {
        assembly {
            let x := num1.slot
            let y := num2.slot
            switch iszero(y)
            case 0 {
                // division by zero error
                revert(0, 0)
            }
            default {
                sstore(ans.slot,div(x, y))

            }
        }
    }
}
