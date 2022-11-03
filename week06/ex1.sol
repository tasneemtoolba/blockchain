// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (finance/VestingWallet.sol)

pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/finance/VestingWallet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VestingWalletGenerated is VestingWallet, Ownable {
    constructor(
        address beneficiaryAddress,
        uint64 startTimestamp,
        uint64 durationSeconds
    ) VestingWallet(beneficiaryAddress, startTimestamp, durationSeconds) {}

    function withdraw(address payable to) public onlyOwner {
        to.transfer(address(this).balance);
    }

    function withdraw(IERC20 token, address payable to) public onlyOwner {
        token.transfer(to, token.balanceOf(address(this)));
    }
}

contract contractsHolder {
    uint64 public vestingDuration = 86400; /// in seconds
    mapping(address => VestingWalletGenerated) public empolyeesWallets; // given employee you can get the wallet
    mapping(address => bool) public empolyeesWalletExists;
    address developerOwner;
    VestingWalletGenerated[] vestingWallets;

    constructor() {
        developerOwner = msg.sender;
        //  vestingDuration should be a big number tho, not only 86400
        empolyeesWallets[msg.sender] = new VestingWalletGenerated(
            msg.sender,
            uint64(block.timestamp),
            vestingDuration
        );
    }

    function createWallet(address beneficiaryAddress, uint64 durationSeconds)
        public
    {
        require(developerOwner == msg.sender);
        // I will use now instead of uint64 startTimestamp, because it is less effort
        VestingWalletGenerated w = new VestingWalletGenerated(
            beneficiaryAddress,
            uint64(block.timestamp),
            durationSeconds
        );
        vestingWallets.push(w);
        empolyeesWallets[beneficiaryAddress] = w;
        empolyeesWalletExists[beneficiaryAddress] = true;
    }

    function releaseToken(address token) public {
        require(empolyeesWalletExists[msg.sender], "you don't have wallet");
        empolyeesWallets[msg.sender].release(token);
    }

    function retrieveAllWallets()
        public
        view
        returns (VestingWalletGenerated[] memory)
    {
        require(msg.sender == developerOwner);
        return vestingWallets;
    }

    // withdraw vesting wallet given employee's address,
    function withDrawWallet(address employee) public {
        require(msg.sender == developerOwner);
        empolyeesWallets[employee].withdraw(payable(address(developerOwner)));
    }
    // withdraw vesting wallet given employee's address, and a token
    function withDrawWallet(IERC20 token, address employee) public {
        require(msg.sender == developerOwner);
        empolyeesWallets[employee].withdraw(token, payable(address(developerOwner)));
    }
}
