pragma solidity ^0.8.0;

contract Subscription {
    enum State {inactive, active}
    State public state;
    
    address payable public owner;
    uint public subscriptionFee;
    
    mapping(address => uint) public subscriptions;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }
    
    modifier onlyWhileActive() {
        require(state == State.active, "Subscription service is not currently active.");
        _;
    }
    
    constructor(uint _subscriptionFee) {
        owner = payable(msg.sender);
        subscriptionFee = _subscriptionFee;
        state = State.inactive;
    }
    
    function activateSubscription() public onlyOwner {
        state = State.active;
    }
    
    function subscribe(uint _periodMonths) public payable onlyWhileActive {
        require(_periodMonths > 0, "Subscription period must be greater than zero.");
        uint totalFee = subscriptionFee * _periodMonths;
        require(msg.value == totalFee, "Incorrect subscription fee.");
        subscriptions[msg.sender] += block.timestamp + (_periodMonths * 30 days);
    }
    
    function checkSubscription(address subscriber) public view returns (bool) {
        return subscriptions[subscriber] >= block.timestamp;
    }
    
    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }
}
