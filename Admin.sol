//"SPDX-License-Identifier: MIT"

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";


  
pragma solidity >=0.6.11;

contract Admin is Ownable {
    mapping(address => bool)whitelist;
    mapping(address => bool)blacklist;

    event Whitelisted(address _toWhiteList, string text );
    event Blacklisted(address _toBlacklist, string text );
    // un seul événement réutilisable:
    // event isListed(address _isListed, string text);

    function whitelist(address _toWhiteList) public onlyOwner returns(bool){
        whitelist[_toWhiteList] = true;
        emit Whitelisted(_toWhiteList, "is now white listed");
        return true;
    }

    function blacklist (address _toBlacklist) public onlyOwner returns(bool){
        blacklist[_toBlacklist] = true;
        emit Blacklisted(_toBlacklist, "is now blacklisted");
        return true;
    }

    function isBlacklisted (address _toCheck) public returns(bool){
        if(blacklist[_toCheck] == true){
            emit Blacklisted(_toCheck, "is black listed");
            return  true;
        } else {
            emit Blacklisted(_toCheck, "is not black listed");
            return false ;
        }
    }

    function isWhiteListed (address _toCheck) public returns(bool){
        if(whitelist[_toCheck] == true){
            emit Whitelisted(_toCheck, "is white listed");
            return  true;
        } else {
            emit Whitelisted(_toCheck, "is not white listed");
            return false ;
        }
    }

    function removeFromBlackList (address _toRemove) public onlyOwner {
        blacklist[_toRemove] = false; 
    }

    function removeFromWhiteList (address _toRemove) public onlyOwner {
        whitelist[_toRemove] = false;
    }
}