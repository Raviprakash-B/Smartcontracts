//SPDX-License-Identifier:GPL-3.0

pragma solidity >=0.5.0 <=0.9.0;

contract Government{
    address[] public citizens; //Collection of citizens
    address[] public officials;
    address payable owner; //address of a owner i.e. Government is the owner
    //This mapping returns whether the address ee are providing is official or citizen by keeping tracking
    mapping (address => bool) public isOfficial;

    constructor() public{
        owner = payable(msg.sender); //Make payable beacuse it can recieve any financial support 
    }  

    //Citizens can reigister themselves EX:- during covid Govt allows users to register for the vaccination themselves
    //Anybody can call this function
    function registerAsCitizen() public{
        //Do not allow officials as citizens
        require(!isOfficial[msg.sender],"Cannot Register as Citizen, already registered as official");
        //update array
        citizens.push(msg.sender);
    } 

    function registerAsOfficial() public {
        //Do not allow citizens as citizens
        require(!isOfficial[msg.sender], "Cannot register as official, already registerd as citizen");
        officials.push(msg.sender);
        //This is we are mappining in mapping isOfficial
        isOfficial[msg.sender] = true;
    }

    //Caste your votes
    //To organise funds,organise voting, to get special previlage to the candidate this conditions will help
    function vote(address candidate)public{
        require(!isOfficial[msg.sender], "Officials cannot vote");
        //Candidate who is registering themselves are not the officials
        require(isOfficial[candidate], "Candidate must be registered as official");
    }

    //Only officials should propose laws for voting
    function proposeLaw(string memory proposal) public{
        require(isOfficial[msg.sender], "Only officials can propose laws.");
    }

    //This function helps Proposal come to life by taking action
    function enactLaw(string memory proposal)public {
        require(msg.sender == owner, "Only the Owner can enact Laws");
    }

    //Print all the officials in list by usin array
    function getOfficials() public view returns (address[] memory){
        return officials;
    }

    //Print all the officials in list by usin array
    function getCitizens() public view returns (address[] memory){
        return citizens;
    }

    //Grant access
    function grantAccess(address payable user)public {
        require(msg.sender == owner,"Only the owner can grant access.");
        //Once we provide the access we have to update the address of the owner
        owner = user;
    }

    //Revoke access
    function revokeAccess(address payable user) public{
        require(msg.sender == owner,"Only owner can revoke access");
        //The person who is calling the function is not owner
        require(user != owner,"Cannot revoke access forthe current owner.");
        owner = payable(msg.sender);
    }
    
    //After certain period if we want to destroy the entire contract 
    function destroy() public {
        //owner is having permission to destoy the contract
        require(msg.sender == owner,"Only the owner can destroy the contract");
        selfdestruct(owner); //IF WE PASS OWNER TO DESTRUCT no one access the contract
    }


}
