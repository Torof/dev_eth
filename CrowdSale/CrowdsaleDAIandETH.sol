// SPDX-License-Identifier: MIT
pragma solidity 0.6.11;

import "./Token.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

//Maybe add a structure for the caller


///@notice Contract is started on 9th of November.
///@notice private sale from 9th to 19th of November
///@notice Presale from 19th to 29th of November


contract Crowdsale {

    uint deployTime;                                  /* save deployment time*/
    uint public privateSaleTimeLimit = 1605441600;   ///@notice 15/11/2020 at 12pm
    uint public preSaleTimeLimit = 1605873600;       ///@notice 20/11/2020 at 12pm
    uint public publicSaleTimeLimit = 1606305600;    ///@notice 25/11/2020 at 12pm
    
    uint public rateETH = 100;
    uint public rateDAI = 1000;
    uint EthersReceived;                  // how many ethers received by the contract, from sales functions
    uint target = 2000000;                 //Minimum target
    uint tokensToBeSold = 5000000;        //tokensToBeSold   
    bool CrowdsaleSuccesful;              //If Minimum target is met
    bool shield;
    BruteToken public token;
    IERC20 daitoken = IERC20(0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa);
    
    event PrivateSale(uint, uint);
    event PreSale(uint, uint);
    event PublicSale(uint, uint);

    constructor(uint _totalSupply) public  {
        deployTime = block.timestamp;
        token = new BruteToken(_totalSupply);
   }

    mapping(address => uint) moneySent;
    mapping(address => uint) moneySentinEther;
    mapping(address => uint) moneySentinDai;
    mapping(address => uint) tokensToReceive;
    
    modifier miniMaxiPurchase(address _caller,uint _amount, uint _mini, uint _maxi){
        require(moneySent[_caller] + _amount >= _mini  && moneySent[_caller] + _amount <= _maxi , "not the right amount");
        _;
    }
    
    
    
     ///@dev  behaviour on receiving ether. Will automatically act in function of session in progress
    receive() external payable {
        require(block.timestamp < publicSaleTimeLimit, "Sale is over");
        
        if(block.timestamp > deployTime && block.timestamp < privateSaleTimeLimit ) {
          privateSale(msg.value, msg.sender, 25, 600, rateETH);
          moneySentinEther[msg.sender] += msg.value;
        }
        if(block.timestamp > privateSaleTimeLimit  && block.timestamp < preSaleTimeLimit ) {
          preSale(msg.value, msg.sender, 12, 5000, rateETH);
          moneySentinEther[msg.sender] += msg.value;
        }
        if(block.timestamp > preSaleTimeLimit && block.timestamp < publicSaleTimeLimit ) {
          publicSale(msg.value, msg.sender, 3, 29, rateETH);
          moneySentinEther[msg.sender] += msg.value;
        }
    }
    
    ///@dev pay in DAI
    function payInDai(uint _amountInDai) external{
        if(block.timestamp > deployTime && block.timestamp < privateSaleTimeLimit ) {
          privateSale(_amountInDai, msg.sender, 11000, 265000, rateDAI);
          moneySentinDai[msg.sender] += _amountInDai;
        }
        if(block.timestamp > privateSaleTimeLimit  && block.timestamp < preSaleTimeLimit ) {
          preSale(_amountInDai, msg.sender, 5300, 2206000, rateDAI);
          moneySentinDai[msg.sender] += _amountInDai;
        }
        if(block.timestamp > preSaleTimeLimit && block.timestamp < publicSaleTimeLimit ) {
          publicSale(_amountInDai, msg.sender, 1300, 12800, rateDAI);
          moneySentinDai[msg.sender] += _amountInDai;
        }
    }
    
    ///@dev privateSale session with rates and mini/maxi amounts
    function privateSale(uint _amount, address _caller, uint _mini, uint _maxi, uint _rate) internal miniMaxiPurchase(_caller, _amount, _mini, _maxi){
        uint _tokensToReceive = _rate  * _amount  + (_amount / 10**16 * 40);
        require(tokensToBeSold - _tokensToReceive > 4000000, "limit reached");
       
        tokensToReceive[_caller] += _tokensToReceive;
        tokensToBeSold -= _tokensToReceive;
        emit PrivateSale(_amount, _tokensToReceive);
    }
    
    ///@dev preSale session with rates and mini/maxi amounts
    function preSale(uint _amount, address _caller, uint _mini, uint _maxi, uint _rate) internal miniMaxiPurchase(_caller, _amount, _mini, _maxi){
        uint _tokensToReceive = _rate  * _amount  + (_amount / 10**16 * 20);
        require(tokensToBeSold - _tokensToReceive > 1000000, "limit reached");
        
        tokensToReceive[_caller] = _tokensToReceive;
        tokensToBeSold -= _tokensToReceive;
        emit PreSale(_amount, _tokensToReceive);
    }
    
    ///@dev preSale session with rates and mini/maxi amounts
    function publicSale(uint _amount, address _caller, uint _mini, uint _maxi, uint _rate) internal miniMaxiPurchase(_caller, _amount, _mini, _maxi){
        uint _tokensToReceive = _rate  * _amount;
        require(tokensToBeSold - _tokensToReceive> 0, "all tokens already sold");
        
        tokensToReceive[_caller] = _tokensToReceive;
        tokensToBeSold -= _tokensToReceive;
        emit PublicSale(_amount, _tokensToReceive);
    }
    
    function withdrawDAI(address _caller) internal {
        daitoken.transfer(msg.sender, moneySentinDai[_caller]);
    }
    
    
    ///@dev once crowdsale is over send either tokens or refunds
    function withdraw() external {
        require(block.timestamp > publicSaleTimeLimit);
        
        if(tokensToBeSold < target){
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
            address(this).transfer(moneySentinEther[msg.sender]);
            address _caller = msg.sender;
            withdrawDAI(_caller);
            shield = false;
        }
    }
}
