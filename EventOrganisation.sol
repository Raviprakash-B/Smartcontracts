//SPDX-License-Identifier:GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract EventOrganisation{

//Consists of 3 Entities Organiser, Event, Attendee
struct Event{
    address organiser;
    string name;
    uint date;  //Initially it is zero if no events created
    uint price;
    uint ticketCount;
    uint ticketRemaining;
}
mapping (uint => Event) public events;//This Mapping contains all the details of the event 
mapping(address=>mapping(uint=>uint))public tickets;  //This will,have the information regarding the tickets of the event
uint public nextId;

function createEvent(string calldata name, uint date, uint price,uint ticketCount)public{
    require(block.timestamp < date,"You Cannot create an event for the past Date"); 
    require(ticketCount > 0,"Ticket count must be greater than 0");
    events[nextId] = Event(msg.sender,name,date,price,ticketCount,ticketCount); //The person who call this function is a organiser //Number of remaning and total ticket are same
    nextId++; //for the next event we need to have new uid
}

function buyTicket(uint id,uint quantity) public payable{
    //if we have 2 events then events[2] since we have mapped events with uint below the id is we have to give manually if we give id then we can fetch the event data
    require(events[id].date != 0, "Event does not exist"); //Initially when no event created in the above functionfor a particular id the date field be zero 
    require(events[id].date > block.timestamp,"Event has Ended"); 
    Event storage _event = events[id]; //this helps us in pointing towards our mapping
    //Checking what is the price of One Ticket
    require(msg.value==(_event.price*quantity), "Ether is not Enough"); 
    require(_event.ticketRemaining >= quantity, "NoT Enough ticket Left");
    _event.ticketRemaining -= quantity; //Subtract from the remaining tickets from the quantity if someone buys the ticket
    //Enter the information in the nested mapping
    tickets[msg.sender][id] += quantity; //the person who clls the function is buying tickets for particular id with total number of tickets he has bought
} 
function transferTicket(uint id, uint quantity, address to) public {
    require(events[id].date != 0, "Event does not exist"); 
    require(events[id].date > block.timestamp,"Event has Ended"); 
    //Checkif the person who is transaferring the tickets is having the enough tickets are not with nested mapping
    require(tickets[msg.sender][id] > quantity, "You do not have enougn tickets");
    //if the above statement excutes the decrease the quantity of the tickets from the user
    tickets[msg.sender][id] -= quantity;
    //Increase the quantity of the to address the one whi recieved tickets
    tickets[to][id] += quantity;
}
}
