//"SPDX-License-Identifier: MIT"

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

pragma solidity 0.6.11;

contract pushPayment is Ownable {
mapping(address => uint) credits;

    function allowForPull(address _receiver, uint _amount) private onlyOwner {
        credits[_receiver] = _amount;
    }

    function withdrawal() public {
        uint amount = credits[msg.sender]
        require( amount !=0);
        require(address(this).balance >= amount);

        credits[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}