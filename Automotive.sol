//SPDX-License-Identifier:GPL-3.0

pragma solidity ^0.8.17;
contract Automotive{
    //Declaring State Variable
    address public owner; //person who is going to seploy the contract
    mapping(address => bool) public buyers; //It allow us to identify who is the buyer gives true/false
    string public vehicleMake; //Info about vehicle
    string public vehicleModel;
    uint public price;

    //Everytime the sales and registrtion happens in the contract we have to initialize the event
    event purchase(address buyer,string make,string model,uint price);

    //Updating owner
    constructor() public{
        owner = msg.sender;
    }

    function buyVehicle(string memory _make, string memory _model) public payable
    {
        require(msg.value >=price); //if amount is >= price they can buy
        require(buyers[msg.sender] == false);
        vehicleMake = _make;
        vehicleModel = _model;
        //price = _price;
        buyers[msg.sender] =true;
        emit purchase(msg.sender,_make,_model,price);
    }

    //Setting price
    function setPrice(uint _price) public{ //Owner will set the price
        require(msg.sender == owner); //Only owner should set the price
        price = _price;
    }
    function checkOwnership() public view returns (bool){   //to check who is the owner of the vehicle
        return buyers[msg.sender]; // gives true if he/she is a buyer
    }
}
