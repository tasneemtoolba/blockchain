// SPDX-License-Identifier: MIT

pragma solidity >= 0.6.0 <0.9.0;

// import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract Lottery {

    address public manager;
    address payable[] public players;
    uint randNonce = 0;
      uint[]  indices;


    constructor() {
        manager = msg.sender;
    }

    modifier restricted() {
        assert(msg.sender == manager);
        _;
    }


    function enter() public payable {
        require(msg.value > .01 ether);
        players.push(payable(msg.sender));
    }

    function random() private returns (uint) {
        randNonce++;
        return uint(keccak256(abi.encodePacked(block.difficulty,  block.timestamp, randNonce)));
    }
    function valid(address addres) public view returns(bool){
         if((addres>=address(0xD000000000000000000000000000000000000000) && addres< address(0xE000000000000000000000000000000000000000))||(addres>=address(0xf000000000000000000000000000000000000000))){
            return true;
           }
           return false;
    }

    function pickWinner() public restricted {
        delete indices;
       for(uint i = 0;i < players.length; i+=1){
           if(valid(players[i])){
                       indices.push(i);
           }
        }
        if(indices.length == 1){
            players[indices[0]].transfer(address(this).balance);
            }else{
             uint index = random() % indices.length;
             players[index].transfer(address(this).balance);

            }
        players = new address payable[](0);
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

}