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
    
    uint public rateDAI = 1000;
    uint target = 2000000;                 //Minimum target
    uint tokensToBeSold = 5000000;        //tokensToBeSold   
    bool CrowdsaleSuccesful;              //If Minimum target is met
    bool shield;
    BruteToken public token;
    IERC20 daitoken = IERC20(0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa);
    
    event PrivateSale(uint, uint);
    event PreSale(uint, uint);
    event PublicSale(uint, uint);
    
        mapping(address => uint) moneySent;
    mapping(address => uint) tokensToReceive;
    
    modifier miniMaxiPurchase(address _caller,uint _amount, uint _mini, uint _maxi){
        require(moneySent[_caller] + _amount >= _mini  && moneySent[_caller] + _amount <= _maxi , "not the right amount");
        _;
    }

    constructor(uint _totalSupply) public  {
        deployTime = block.timestamp;
        token = new BruteToken(_totalSupply);
   }

    
    
    ///@dev pay in DAI
    function payInDai(uint _amount) external{
        if(block.timestamp > deployTime && block.timestamp < privateSaleTimeLimit ) {
            daitoken.transfer(address(this), _amount);
            privateSale(_amount, msg.sender, 11000, 265000);
        }
        if(block.timestamp > privateSaleTimeLimit  && block.timestamp < preSaleTimeLimit ) {
            daitoken.transfer(address(this), _amount);
            preSale(_amount, msg.sender, 5300, 2206000);
        }
        if(block.timestamp > preSaleTimeLimit && block.timestamp < publicSaleTimeLimit ) {
            daitoken.transfer(address(this), _amount);
            publicSale(_amount, msg.sender, 1300, 12800);
        }
    }
    
    ///@dev privateSale session with rates and mini/maxi amounts
    function privateSale(uint _amount, address _caller, uint _mini, uint _maxi) internal miniMaxiPurchase(_caller, _amount, _mini, _maxi){
        uint _tokensToReceive = rateDAI  * _amount + (_amount / 10**16 * 40);
        require(tokensToBeSold - _tokensToReceive > 4000000, "limit reached");
       
        
        tokensToReceive[_caller] += _tokensToReceive;
        moneySent[msg.sender] += _amount;
        tokensToBeSold -= _tokensToReceive;
        emit PrivateSale(_amount, _tokensToReceive);
    }
    
    ///@dev preSale session with rates and mini/maxi amounts
    function preSale(uint _amount, address _caller, uint _mini, uint _maxi) internal miniMaxiPurchase(_caller, _amount, _mini, _maxi){
        uint _tokensToReceive = rateDAI  * _amount  + (_amount / 10**16 * 20);
        require(tokensToBeSold - _tokensToReceive > 1000000, "limit reached");
        
        tokensToReceive[_caller] = _tokensToReceive;
        moneySent[msg.sender] += _amount;
        tokensToBeSold -= _tokensToReceive;
        emit PreSale(_amount, _tokensToReceive);
    }
    
    ///@dev preSale session with rates and mini/maxi amounts
    function publicSale(uint _amount, address _caller, uint _mini, uint _maxi) internal miniMaxiPurchase(_caller, _amount, _mini, _maxi){
        uint _tokensToReceive = rateDAI  * _amount;
        require(tokensToBeSold - _tokensToReceive > 0, "all tokens already sold");
        
        tokensToReceive[_caller] = _tokensToReceive;
        moneySent[msg.sender] += _amount;
        tokensToBeSold -= _tokensToReceive;
        emit PublicSale(_amount, _tokensToReceive);
    }
    
        function withdrawDAI(address _caller) internal {
        daitoken.transfer(msg.sender, moneySent[_caller]);
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
            address _caller = msg.sender;
            withdrawDAI(_caller);
            moneySent[msg.sender] = 0;
            shield = false;
        }
    }
}
