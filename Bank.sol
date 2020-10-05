//SPDX-License-Identifier: MIT

pragma solidity >=0.6.11;

import "/home/torof/node_modules/@openzeppelin/contracts/math/SafeMath.sol";

contract Bank {
    using SafeMath for uint;
    mapping(address => uint)_balances;

    function deposit(uint _amount) public {
        _balances[msg.sender] += _amount;
    }

    function transfer(address _recipient, uint _amount) public {
        require(_recipient != address(0));
        require(_balances[msg.sender] >= _amount);
        _balances[msg.sender] = _balances[msg.sender].sub(_amount);
        _balances[_recipient] = _balances[_recipient].add(amount);

    }

    function balanceOf(address _address) public view returns (uint){
       // require( _address = msg.sender); //to prevent everyone from accessing others' balances. Could also implement an "authorized list" modifier
        return _balances[_address];
    }
}

