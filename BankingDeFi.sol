//SPDX-License-Identifier:GPL-3.0

pragma solidity >=0.5.0 <=0.9.0;
contract banking {
    mapping (address =>uint) public balances; //keeping track of address
    address payable owner;//Keep track of the owner of the contract

    //Update the owner as a payable
    constructor() public {
        owner = payable (msg.sender);
    }

    //Basic in every de-fi app to use deposit function
    function deposit() public payable {
        require(msg.value>0,"Deposit amount should be greater than 0");
        //balance is the mapping in that we are passing the address of the person whom is depositing and updating the Balance
        balances[msg.sender] += msg.value;
    }

    //Withdraw funds from contract
    function withdraw(uint amount) public{
        require(msg.sender == owner,"Only Owner can withdraw funds");
        require(amount <= balances[msg.sender],"Insufficient Funds");
        require(amount > 0,"Amount must be greater than 0");
        //Withdraw
        //Payble allows owner to transfer amount to his/her account 
        payable(msg.sender).transfer(amount);
        //Updating data in our mapping
        balances[msg.sender] -= amount;
    }

    //Transfering funds to the recipent
    function transferFunds(address payable recipient,uint amount) public {
        require(amount <= balances[msg.sender],"InSuffitient Funds");
        require(amount > 0,"Transfetr amount should be greater than 0");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
    }

    //Check Balance
    //uint because balance is going to be in number
    function getBalance(address payable user) public view returns(uint256)
    {
        return balances[user];
    }

    //If we have fund and we want to access to anybody to use our fund behalf of me
    function grantAccess(address payable user)public{
        //Only owner can provide the access
        require(msg.sender == owner,"Only the owner can grant access");
        owner = user;
    }

    //if we have provided access and we need to remove that access the we have to use this function
    function revokeAccess(address payable user) public{
        require(msg.sender == owner,"Only the owner can grant access");
        require(user != owner,"Cannot revoke access for the contract owner");
        owner = payable (msg.sender);  //payable becuse we are going to provide different address initially the owner is master and he is having payable access but in earlier
        //function we have transffered payable access to other address so we need explicitly use payable  
    }

    //After certain period if we want to destroy the entire contract 
    function destroy() public {
        //owner is having permission to destoy the contract
        require(msg.sender == owner,"Only the owner can destroy the contract");
        selfdestruct(owner); //IF WE PASS OWNER TO DESTRUCT no one access the contract
    }
}

