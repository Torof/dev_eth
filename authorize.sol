pragma solidity 0.6.11;


contract Whitelist {

   mapping(address=> bool) whitelist;

   event Authorized(address _address, string text); 

function authorize (address _address) public returns(bool whitelisted){

whitelist[_address] = true

emit Authorized(_address, "is authorized")

return true

}

}
