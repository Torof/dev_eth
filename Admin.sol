//"SPDX-License-Identifier: MIT"

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";


  
pragma solidity >=0.6.11;

contract Admin is Ownable {
    mapping(address => bool)public whitelist;
    mapping(address => bool)public blacklist;

    event Whitelisted(address _toWhiteList, string text );
    event Blacklisted(address _toBlacklist, string text );
/* un seul événement réutilisable:
    event isListed(address _isListed, string text);  */

    function whitelist(address _toWhiteList) public onlyOwner {
        whitelist[_toWhiteList] = true;
        emit Whitelisted(_toWhiteList, "whitelisted");
    }

    function blacklist (address _toBlacklist) public onlyOwner{
        blacklist[_toBlacklist] = true;
        emit Blacklisted(_toBlacklist, "blacklisted");
    }
    
     function removeFromBlackList (address _toRemove) public onlyOwner {
        blacklist[_toRemove] = false; 
    }

    function removeFromWhiteList (address _toRemove) public onlyOwner {
        whitelist[_toRemove] = false;
    }

/* @dev  IsBlacklisted and is Whitelisted not necessary  if mappings declared public */
    function isBlacklisted (address _toCheck) public returns(bool){
        if(blacklist[_toCheck] == true){
            emit Blacklisted(_toCheck, "is blacklisted");
            return  true;
        } else {
            emit Blacklisted(_toCheck, "not blacklisted");
            return false ;
        }
    }

    function isWhiteListed (address _toCheck) public returns(bool){
        if(whitelist[_toCheck] == true){
            emit Whitelisted(_toCheck, "is whitelisted");
            return  true;
        } else {
            emit Whitelisted(_toCheck, "not whitelisted");
            return false ;
        }
    }

}
