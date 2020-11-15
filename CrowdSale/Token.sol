//SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract BruteToken is ERC20 {
    
    
    constructor(uint _initialSupply) public ERC20("BruteToken", "BrT"){
        _mint(msg.sender, _initialSupply);
    }
}