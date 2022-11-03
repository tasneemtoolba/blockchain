// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (finance/VestingWallet.sol)

pragma solidity >= 0.6.0 <0.9.0;

import "@openzeppelin/contracts/finance/VestingWallet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract VestingWalletGenerated is VestingWallet , Ownable{
    constructor(address beneficiaryAddress, uint64 startTimestamp, uint64 durationSeconds) VestingWallet( beneficiaryAddress, startTimestamp,  durationSeconds) {}
    function withdraw(address payable to) onlyOwner public{
        to.transfer(address(this).balance);
    }
}

contract contractsHolder  {
    uint64 public vestingDuration = 86400; /// in seconds
    mapping(address => VestingWalletGenerated) public empolyeesWallets;// given employee you can get the wallet
    mapping(address => bool)public empolyeesWalletExists;
    address developerOwner;
    VestingWalletGenerated[] vestingWallets;

    constructor () {
        developerOwner = msg.sender;
    }
    function createWallet (address beneficiaryAddress, uint64 durationSeconds)public {
        require(developerOwner == msg.sender);
        // I will use now instead of uint64 startTimestamp, because it is less effort
        VestingWalletGenerated w = new VestingWalletGenerated(beneficiaryAddress, uint64(block.timestamp), durationSeconds);
        vestingWallets.push(w);
        empolyeesWallets[beneficiaryAddress] = w;
        empolyeesWalletExists[beneficiaryAddress]=true;
    }
    function retrieveAllWallets()public view returns (VestingWalletGenerated[] memory){
        require(msg.sender == developerOwner);
        return vestingWallets;
    } 
    // withdraw vesting wallet given employee's address, 
    function withDrawWallet(address employee)public{
        require(msg.sender == developerOwner);
        empolyeesWallets[employee].withdraw(payable(address(developerOwner)));
    }
   
}
