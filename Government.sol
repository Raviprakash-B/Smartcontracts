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
}
