pragma solidity ^0.4.8;
contract CreditScore {
    
    
    function newloanHistory( address Cashprovider, address Cashtaker, uint amountDue, uint _instalments, address loanID) returns (address );
    
    function populateHistory(address loanID, uint _amount);

    function getlength(address loanID) returns (uint);
    
    function getAmount( address investor, address loanID, address owner,  uint monthno) returns (uint Amount);
    
}

contract Loan {
    
    function changeonwership( address cdsseller);
    
}
contract CDSContract{
    
     /* Varaibles for the CDS contract */

    address public CdsBuyer;
    address public CdsSeller;
    uint256 public AmtInsured;
    uint public Premium;    
    uint public startDate;
    uint public endDate;
    address public loanID;
    
   
    enum State { Initialized, Release }
    State public status;
    address myAddress;
    bool public active;
    
    address _CreditScore = 0x997480e4F88c69f8CAd1E6AE0aEbA2e6f88Cdd01 ; // initialize this before running the code
    CreditScore userHisory = CreditScore(_CreditScore); 
    
    
    address _Loan = 0x997480e4F88c69f8CAd1E6AE0aEbA2e6f88Cdd01 ; // initialize this before running the code
    Loan newowner = Loan(_Loan); 
    
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
    
    
    
    modifier onlyCdsSeller()
    {
        if (msg.sender != CdsSeller) throw;
        _;
    }

    modifier onlyCdsBuyer()
    { 
        if (msg.sender != CdsBuyer) throw;
        _;
    }

    /* The contract constructor*/
    function CDSContract (address cdsBuyer, uint premium, uint _blocknum, uint256 _amtinsured) payable
    {
        
    myAddress = this;
    CdsSeller = msg.sender;
    CdsBuyer = cdsBuyer;
    Premium = premium;
    AmtInsured = _amtinsured;
    endDate = _blocknum;
    
    }

    /* A function that allows the cds buyer to pay the montly or yearly premium to the cds seller*/
    function montlypremium() onlyCdsBuyer payable returns (bool res) 
    {
    
  
        active= true;
        startDate = now;
        if (!CdsSeller.send(Premium)) throw;
        loanID = userHisory.newloanHistory(CdsSeller, CdsBuyer, AmtInsured,  Premium, myAddress );
        userHisory.populateHistory(loanID, Premium);
        status = State.Initialized;
        return true;
    
    }
     
    /* The function that allows the cds buyer to pay the cds buyer if a default occurs  */
    function payback(uint monthno,  address loanID) onlyCdsSeller onlyCdsBuyer payable returns (bool res) 
    {
        if (status != State.Initialized) throw;
        address investor =CdsBuyer;
        address owner = CdsSeller;
        uint value = userHisory.getAmount( investor, loanID, owner, monthno);
    
        if (!CdsBuyer.send(value)) throw;
   
        // call the cdsloan function to change name or onwership of the loan contract to the cdsseller.
        newowner.changeonwership(CdsSeller);
   
        status == State.Release;
    }

    /* The function is run by the cds seller to determine if a default occurs and if it does, the contract terminates*/
    function reportDefault (uint _amount) onlyCdsSeller
    
    {
    
        uint i;
        uint j;
        uint amountleft= _amount;
        
       
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
               suicide (CdsSeller);
              
        }
    }

    
    
}
    

