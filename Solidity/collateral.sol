pragma solidity ^0.4.8;

    
contract CreditScore {
    
    
    function getAmount( address investor, address loanID, address owner,  uint monthno) returns (uint Amount);
    
}

contract Collateral{
    
    /* Variables for the Collateral contract */
    
    address public owner;
    address public investor;
    uint public endDate;
     uint public start;
    enum State {Initialized, Set, Released}
    State public status;
    uint [] monthlist;
    
    modifier onlyOwner() {
        if (msg.sender != owner){
            throw;
        }
        _;
    }
    
    modifier onlyInvestor() {
        if (msg.sender != investor){
            throw;
        }
        _;
    }
    
    /* constructor function */
    function Collateral () {
        
        owner= msg.sender;
        
    }
    
    /* Allow the debtor to put the collateral into the contract */
    function () onlyOwner payable{
        
    }
    
    
    /* This function initializes the variables */
    function serve (address _investor, uint endate) onlyOwner{
        if (status!= State.Initialized){
        throw;
        }
        
        start = block.number;
        status= State.Set; 
        investor= _investor;
        endDate=endate;
    }
    
    /* This function transfer the amount of default to the lender*/
    function payLender (uint monthno , address loanID ) onlyInvestor {
        if (status != State.Set){
        throw;
        }
        address _creditscore  = 0x997480e4F88c69f8CAd1E6AE0aEbA2e6f88Cdd01;
        CreditScore userdefault = CreditScore(_creditscore);
        uint value = userdefault.getAmount( investor, loanID, owner, monthno);  
        
        
        for(uint i=0; i< monthlist.length; i++)
        {
            if (monthlist[i] == monthno) throw;
        }
        
        if ( block.number > endDate)throw;
        
        if (value > 0)   
        {
        
        
        if (this.balance > 0 && this.balance <= value ){
            
            if (!msg.sender.send(this.balance)) throw;
            monthlist.push(monthno);
        }
        
        
        if (this.balance >= value){
          
            if (!msg.sender.send(value)) throw;
            monthlist.push(monthno);
        }
        
        }
        else return;
    }
    
    
    /* This transfer the money in the contract back to the debtor if no default occurs */
    function cancel () onlyOwner{
        if (block.number < endDate) throw;
        if (status == State.Released){
            throw;
        }
        suicide(owner);
    }
    
}