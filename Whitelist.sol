//"SPDX-License-Identifier: MIT"

pragma >= 0.6.11;

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Whitelist is Ownable {

    mapping(address => bool)whitelist;
    event Whitelisted(address _toWhiteList, string text );

    function whitelist(address _toWhiteList) public onlyOwner returns(bool){
        whitelist[_toWhiteList] = true;
        emit Whitelisted(_toWhiteList, "is now white listed");
        return true;
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

       function removeFromWhiteList (address _toRemove) public onlyOwner {
        whitelist[_toRemove] = false;
    }

}

