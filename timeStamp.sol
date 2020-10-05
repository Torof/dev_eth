//"SPDX-License-Identifier: MIT"
pragma solidity >=0.6.11;

contract Time {

function getTime() public view returns(uint time) {

   uint blockTime = block.timestamp;
   return blockTime;

}

}
