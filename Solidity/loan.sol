pragma solidity ^0.4.8;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract CreditScore {
    
    
    function newloanHistory( address Cashprovider, address Cashtaker, uint amountDue, uint _instalments, address loanID) returns (address );
        
    function populateHistory(address loanID, uint _amount);

    function getlength(address loanID) returns (uint);
   
}

contract Loan is usingOraclize {

 /* Variables for the Loan contract */
 
    address public Cashprovider;
    address public Cashtaker;
    uint256 public Principal;
    uint256 public amountLeft;
    uint public interest;       // modified the interest tot a fixed amount
    uint public Instalments;           // how much to be paid per instalments
    uint public startDate;
    uint public endDate;
    address public loanID;
    mapping (address => uint) public Balance;
    enum State {Initialized, Release}
    State public status;
    address myAddress;
    bool public active;
    bool public Defaulted; 
    bool check;
    uint public amountDue ; //total amount
     
    address _CreditScore = 0x997480e4F88c69f8CAd1E6AE0aEbA2e6f88Cdd01 ; // initialize this before running the code
          
    CreditScore userHisory = CreditScore(_CreditScore); 
    
    event DeFaulted (bool defaulted);
    
    
     modifier onlyCashprovider()
    {
        if (msg.sender != Cashprovider) throw;
        _;
    }

    modifier onlyCashtaker()
    { 
        if (msg.sender != Cashtaker) throw;
        _;
    }

    
    /* code to act as a calender for the monthly payment */
	
    uint [13] public array;
    
    uint public counter;
    
    function setCalender(){
    
    array[0]= now ;
    array[1]= now  + 3 minutes;
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

    function EthPrice() {
        update(); // first check at contract creation
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        newEtherPrice(result);
        EthtoUSD = parseInt(result, 2); // let's save it as $ cents
        
    }
    
    function update() payable {
        newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query("URL", "json(https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=BTC,USD,EUR).USD");
    }
    
 /* constructor function */
    
	function Loan (address _borrower, uint _rate, uint _blocknum, uint256 _amount, uint _instalments) 
	{
		myAddress = this;
		Cashprovider = msg.sender;
		Cashtaker = _borrower;
		Principal = _amount;
		interest = _rate;
		endDate = _blocknum;
		Instalments= _instalments;
		status = State.Initialized;
		amountDue= Principal + interest;
		EthPrice();
	}
	
	/* Cashprovider sends money to the contract */
	function ()onlyCashprovider payable{

	}
	
	/* The function is triggered by the debtor in other to withdraw money from the contract */
	function receiveMoney() onlyCashtaker payable returns (bool res) { 
		if (status != State.Initialized) {return;}
    
		if (myAddress.balance >= Principal)
		{
            status = State.Release;
            active= true;
            startDate = now;
            setCalender(); 
            if(!Cashtaker.send(Principal)) throw;
			loanID = userHisory.newloanHistory(Cashprovider, Cashtaker, amountDue,  Instalments, myAddress );
			return true;
        }
        else throw;
    
  
	}
	
	// if the contract was not utilized by the debtor after certain number of blocks, kill the contract
	// in the future this function would implement a modifier function
	function Kill() onlyCashprovider
	{ 
    		if (status == State.Release) throw;
   
    		suicide (Cashprovider);
	}
	
	/* Function to pay the cash provider monthly */
	function payback() onlyCashtaker payable returns (bool res)
	{
  
   
		if (endDate < block.number) throw;
   
		if (msg.value < Instalments && msg.value > 0)
		{

       
			amountLeft = Instalments - msg.value;
			reportDefault (amountLeft);
			check= true;
			if (!Cashprovider.send(msg.value)) throw;
        
		}
    
		else if (msg.value == Instalments)
		{
			check=true;
			reportDefault (0);
			if (!Cashprovider.send(msg.value)) throw;
       
		}
     
		else throw;

	}

	 /* function to report if a default by the organization and update the CreditScore object */
	function reportDefault (uint _amount)
	{
    
        uint i;
        uint j;
        
        if(msg.sender!=Cashtaker)
		{
		
            counter=0;
			for (i = 0 ; i <= 12 ; i++)
			{
            
				if (now > array[i])
				counter ++;
           
            }
        }
        uint lent = userHisory.getlength(loanID);
        if (lent == counter)
        {
              
        }
            
        else if (lent < counter)
        {
            for (j=lent ; j<counter ; j++)
			{
                userHisory.populateHistory(loanID, _amount);  
            }
               
        }
           
       
        
    
    
	}
   
	else 
	{
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
            for (j=lent ; j<counter ; j++)
			{
                userHisory.populateHistory(loanID, Instalments);  
            }
                userHisory.populateHistory(loanID, _amount); 
        }
           
        
    
      
	}
   
}



}
