pragma solidity ^0.4.7;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract CreditScore {
    
    
    function newloanHistory( address Cashprovider, address Cashtaker, uint amountDue, uint _instalments, address loanID) returns (address );
    
    function populateHistory(address loanID, uint _amount);

    function getlength(address loanID) returns (uint);
   
}

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract MyToken {
    /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyToken(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
        ) {
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        totalSupply = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }
    
     function balanceToken(address _user) constant returns (uint256 balance)
    {
        return balanceOf[_user];
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value)
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /* Approve and then comunicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }        

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        if (_value > allowance[_from][msg.sender]) throw;   // Check allowance
        balanceOf[_from] -= _value;                          // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
} 



contract comBond is usingOraclize { 

    /* Varaibles for the Bond contracts */
	
    uint256 public couponRate = 0;  //interest rate in ether
    uint public startDate= 0;
    uint public Maturity= 0;
    uint public tokenPrice;
    uint public amountnow;
    mapping (address => uint256) balanceOf;  // each address in this contract may have tokens. 
    mapping (address => uint256) balances;
    address  Cashtaker;                // the owner is the creator of the smart contract
    MyToken public Token;
    address myAddress;
    uint payment;
    
    address [] listofloan;
    string public defaulted = "No";
   
    address _CreditScore = 0xa ; // initialize this before running the code (holds the address of the credit score contract)
          
    CreditScore userHisory = CreditScore(_CreditScore); 

    modifier onlyCashtaker()
    {
        if (msg.sender != Cashtaker) throw;
        _;
    }

    /* This generates a public event on the blockchain that will notify clients */
    
    event BuyXYZ(string note, address indexed recipient, uint256 value);
    event Defaults(string note, address indexed recipient );
    event PartialDefault(string note, address indexed recipient , uint amount);
    
    // code to act as a calender for the monthly payment
    
    uint [13] public array;
    
    uint public counter;
    
    function setCalender(){
    
    array[0]= now ;
    array[1]= now  + 3 minutes; // this was used in minutes for testing but can be easily replaced with days
    array[2]= now  + 6 minutes;
    array[3]= now  + 9 minutes;
    array[4]= now  + 12 minutes;
    array[5]= now  + 15 minutes;
    array[6]= now  + 18 minutes;
    array[7]= now  + 21 minutes;
    array[8]= now  + 24 minutes;
    array[9]= now  + 27 minutes;
    array[10]= now  + 30 minutes;
    array[11]= now  + 33 minutes;
    array[12]= now  + 36 minutes;
    }
    
    
    /* Oraclize begins here */
    uint public EthtoUSD;

    event newOraclizeQuery(string description);
    event newEtherPrice(string price);

    function EtherPrice() {
        update(); // first check at contract creation
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        newEtherPrice(result);
        EthtoUSD = parseInt(result, 2); // let's save it as $ cents
        // do something with the USD price
    }
    
    function update() payable {
        newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query("URL", "json(https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=BTC,USD,EUR).USD");
    }
    
    /* constructor function */
  
    function comBond(uint256 _tokenPrice, uint256 _couponRate, uint _startDate, uint _maturity, MyToken _mytokenaddress){
      
        couponRate= _couponRate * 1 ether;  
        startDate= _startDate;
        Maturity= _maturity;
        tokenPrice= _tokenPrice * 1 ether;
        Token= MyToken(_mytokenaddress);
        myAddress = this;
        Cashtaker=msg.sender;
    }
     
   /* function that enables investor buy bonds from the organization */
   
    function Purchasebond() payable
    { 
        if (msg.sender != Cashtaker){
            
        if (block.number < startDate || block.number > Maturity) throw;
        
        uint256 amount= msg.value;
        balances[msg.sender]= amount;
        amountnow += amount;
        uint256 value = amount / tokenPrice; 
        balanceOf[msg.sender] = value;
        Token.transfer(msg.sender, value);
        address loanID;
        loanID = userHisory.newloanHistory(Cashtaker, msg.sender, amountnow, 0, myAddress);
        listofloan.push(loanID); 
        BuyXYZ("A token has been purchased", msg.sender, msg.value);   // if the sender is the fund manager then that would mean funds are requires to pay out for the sale of tokens and therefor this ether does not need to be allocated to any specific user, it will be paid out
        }
            
    }

   
    /* withdraws all ether from contract that is then used to purchase assets according to the current portfolio */
    function withdrawETH() onlyCashtaker returns (bool success)
    {
        setCalender(); 
        if(!Cashtaker.send(this.balance)) throw;
        return true;
    }

	/* pay interest to the investors on a monthly basis */
    function Repay() payable returns (bool success)
    {
        if (Maturity < block.number) throw;
        uint256 bal = Token.balanceToken(msg.sender);
        uint256 zeroCoupon = bal * couponRate;
        uint256 amount = bal * tokenPrice;
        payment = (zeroCoupon + amount)/12;
        
        
        
         if (myAddress.balance >= payment){
        balanceOf[msg.sender] == 0;
        reportDefault (0, msg.sender);
        if (!msg.sender.send(payment)) throw;
        return true; 
         }
         
         if (myAddress.balance < payment){
            balanceOf[msg.sender] == 0; // this is set to zero so that the user wont run the function again
            uint duenow= payment - myAddress.balance; 
            reportDefault (duenow, msg.sender);
            if (!msg.sender.send(payment)) throw;
        
            defaulted="Partial Default";
            PartialDefault("The organization has defaulted on partpayment to this address", msg.sender, duenow);
         }
         
          if (myAddress.balance == 0 ){
              if ( balanceOf[msg.sender] > 0)
                {
             reportDefault (payment, msg.sender);
            defaulted="Full Default";
            Defaults("The organization has defaulted on full payment to this address", msg.sender);
                }
              
          }
         
         
    }
	
    /* function to report if a default by the organization an update the CreditScore object */
	function reportDefault (uint _amount, address loanID)
	{
    
        uint i;
        uint j;
        
        if(msg.sender!=Cashtaker){
            counter=0;
        for (i = 0 ; i <= 12 ; i++)
        {
            
            if (now > array[i]){
            counter ++;
           
            }
        }
        uint lent = userHisory.getlength(loanID);
        if (lent == counter)
            {
              
            }
            
        else if (lent < counter)
            {
                for (j=lent ; j<counter ; j++){
                userHisory.populateHistory(loanID, _amount);  
                }
               
            }
           
       
        
    
    
	}
   
	else {
      counter=0;
       for (i=0 ; i<=12 ; i++)
            
        {
            if (now > array[i]){
            counter ++;
           
            }
        }
            
        lent = userHisory.getlength(loanID);
        if (lent == counter)
            {
                userHisory.populateHistory(loanID, _amount);   
            }
            
        else if (lent < counter)
            {
                for (j=lent ; j<counter ; j++){
                userHisory.populateHistory(loanID, payment);  
                }
                userHisory.populateHistory(loanID, _amount); 
            }
           
        
    
      
		}
	}    
    
}
