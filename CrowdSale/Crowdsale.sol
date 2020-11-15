// SPDX-License-Identifier: MIT
pragma solidity 0.6.11;

import "./Token.sol";

///@notice Contract is started on 9th of November.
///@notice private sale from 9th to 19th of November
///@notice Presale from 19th to 29th of November


contract Crowdsale {

   /* uint deployTime;                                  // save deployment time
    uint public privateSaleTimeLimit = 1605441600;   ///@notice 15/11/2020 at 12pm
    uint public preSaleTimeLimit = 1605873600;       ///@notice 20/11/2020 at 12pm
    uint public publicSaleTimeLimit = 1606305600;    ///@notice 25/11/2020 at 12pm
    */
    
    
    uint public deployTime;                                  
    uint public privateSaleTimeLimit; 
    uint public preSaleTimeLimit;     
    uint public publicSaleTimeLimit;
    
    uint public rate = 100;
    uint EthersReceived;                  // how many ethers received by the contract, from sales functions
    uint softCap = 2000;                  //Minimum target
    uint tokensToBeSold = 5000000;        //tokensToBeSold   
    bool CrowdsaleSuccesful;              //If Minimum target is met
    bool shield;
    BruteToken public token;
    
    event PrivateSale(uint, uint);
    event PreSale(uint, uint);
    event PublicSale(uint, uint);

    constructor(uint _totalSupply) public  {
        deployTime = block.timestamp;
        privateSaleTimeLimit = deployTime + 1 minutes;    //for test
        preSaleTimeLimit = deployTime + 2 minutes;       //for test 
        publicSaleTimeLimit = deployTime + 3 minutes;   //for test
        token = new BruteToken(_totalSupply);
   }


    mapping(address => bool) public privateSaleWhitelist;
    mapping(address => bool) public preSaleWhitelist;
    mapping(address => uint) public moneySent;
    mapping(address => uint) public tokensToReceive;
    
    
    ///@dev  behaviour on receiving ether. Will automatically act in function of session in progress
    
    receive() external payable {
        require(block.timestamp < publicSaleTimeLimit, "Sale is over");
        
        if(block.timestamp > deployTime && block.timestamp < privateSaleTimeLimit ) {
          privateSale(msg.value, msg.sender);
        }
        if(block.timestamp > privateSaleTimeLimit  && block.timestamp < preSaleTimeLimit ) {
          preSale(msg.value, msg.sender);
        }
        if(block.timestamp > preSaleTimeLimit && block.timestamp < publicSaleTimeLimit ) {
          publicSale(msg.value, msg.sender);
        }
    }
    
    
    function showSession() external view  returns(string memory){
        if(block.timestamp > deployTime && block.timestamp < privateSaleTimeLimit ) {
          return "private sale";
        }
        if(block.timestamp > privateSaleTimeLimit  && block.timestamp < preSaleTimeLimit ) {
          return "presale";
        }
        if(block.timestamp > preSaleTimeLimit && block.timestamp < publicSaleTimeLimit ) {
          return "public sale";
        }
    }
    
    
    ///@dev behaviour of crowdsale during privateSale
    function privateSale(uint _amount, address _caller) internal {
        require(moneySent[_caller] + _amount >= 25 ether && moneySent[_caller] + _amount <= 600 ether, "not the right amount");
        require(tokensToBeSold - _amount > 4000000, "limit reached");
        uint _tokensToReceive = rate  * _amount + (_amount / 10 * 40);
        
        moneySent[_caller] += _amount;
        tokensToReceive[_caller] += _tokensToReceive;
        EthersReceived += _amount;
        tokensToBeSold -= _tokensToReceive;
        emit PrivateSale(_amount, _tokensToReceive);
    }
    
    function preSale(uint _amount, address _caller) internal {
        require(moneySent[_caller] + _amount >= 12 ether && moneySent[_caller] + _amount <= 5000 ether, "not the right amount");
        require(tokensToBeSold - _amount > 1000000, "limit reached");
        uint _tokensToReceive = rate  * _amount + (_amount / 10* 20);
        
        moneySent[_caller] = _amount;
        tokensToReceive[_caller] = _tokensToReceive;
        EthersReceived += _amount;
        tokensToBeSold -= _tokensToReceive;
        emit PreSale(_amount, _tokensToReceive);
    }
    
    function publicSale(uint _amount, address _caller) internal {
        require(moneySent[_caller] + _amount >= 3 ether && moneySent[_caller] + _amount <= 29 ether, "mini 3 ethers, maxi 29 ethers");
        require(tokensToBeSold - _amount > 0, "all tokens already sold");
        uint _tokensToReceive = rate  * _amount;
        
        moneySent[_caller] = _amount;
        tokensToReceive[_caller] = _tokensToReceive;
        EthersReceived += _amount;
        tokensToBeSold -= _tokensToReceive;
        emit PublicSale(_amount, _tokensToReceive);
    }
    
    function withdraw() external {
        require(block.timestamp > publicSaleTimeLimit);
        
        if(EthersReceived > softCap){
            CrowdsaleSuccesful = true;
        }
        if(CrowdsaleSuccesful == true){
            require(!shield);
            shield = true;            
            token.transfer(msg.sender, tokensToReceive[msg.sender]);
            tokensToReceive[msg.sender] = 0;
            shield = false;
        }
        if(CrowdsaleSuccesful == false){
            require(!shield);
            shield = true;
            address(this).transfer(moneySent[msg.sender]);
            moneySent[msg.sender] = 0;
            shield = false;
        }
    }
}
