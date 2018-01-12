
pragma solidity ^0.4.12;

contract CreditScore 
{
    
   /* A struct to hold the variables of each loan or bond */
    struct CreditHistory{
        address Cashprovider;
        address Cashtaker;
        uint amountDue;
        uint Instalments;
        uint currentmonth;
        uint [] coupons;
    }
   
    uint public numLoans;
    mapping (address => CreditHistory) public CreditHistories;
    event ActivatedEvent(address loanID, uint amount);
    event Length( uint lenght);
    
	
	/* Function to create a new storage for a loan or bond contract*/
    function newloanHistory( address Cashprovider, address Cashtaker, uint amountDue, uint _instalments, address loanID) returns (address ){
        numLoans++;
       
        
        CreditHistories[loanID].Cashprovider=Cashprovider;
        CreditHistories[loanID].Cashtaker=Cashtaker;
          CreditHistories[loanID].amountDue=amountDue;
           CreditHistories[loanID].Instalments=_instalments;
            CreditHistories[loanID].currentmonth= 0;
             CreditHistories[loanID].coupons.push(0); 
       
	    return loanID;
    }
    
    /* Function to update the state of the variables during a monthly payment*/
    function populateHistory(address loanID, uint _amount)
    {
    
       
        CreditHistory storage CH= CreditHistories[loanID];
        CH.coupons.push(_amount); 
        CH.currentmonth++;
        ActivatedEvent(loanID, _amount);
    }
    
	/* A getter function to return the state of the loan */
    function displayHistory(address loanID) public constant returns (address, address, uint, uint, uint, uint[]){
        return(CreditHistories[loanID].Cashprovider, CreditHistories[loanID].Cashtaker, 
        CreditHistories[loanID].amountDue,CreditHistories[loanID].Instalments,
        CreditHistories[loanID].currentmonth,CreditHistories[loanID].coupons);
        
    }
    
	/* A function to return an amount given a specific month */
     function getAmount( address investor, address loanID, address owner,  uint monthno) returns (uint Amount){
        if (CreditHistories[loanID].Cashprovider==investor && CreditHistories[loanID].Cashtaker==owner){
             Amount= CreditHistories[loanID].coupons[monthno];
        }
        return Amount;
    }
    
	
	/* A function to obtain the length of an array given the loan address*/
    function getlength(address loanID) returns (uint)
    {
        uint lent = CreditHistories[loanID].coupons.length;
        return lent;
        Length(lent);
    }
	
    /*A function to change ownership */
    function changename(address cdsseller, address loanID){
        
        CreditHistories[loanID].Cashprovider = cdsseller;
        
    }
}