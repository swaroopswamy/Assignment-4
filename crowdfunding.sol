//0xd9145CCE52D386f254917e481eB44e9943F39138

pragma solidity ^0.8.0;

contract Crowdfunding {
    enum State {inactive, active, completed}
    State public state;
    
    address payable public owner;
    uint256 public fundingGoal;
    uint256 public deadline;
    uint256 public totalFundsRaised;
    
    mapping(address => uint256) public contributions;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }
    
    modifier inState(State _state) {
        require(state == _state, "Invalid state.");
        _;
    }
    
    constructor() {
        owner = payable(msg.sender);
        state = State.inactive;
    }
    
    function startFunding(uint256 _fundingGoal, uint256 _durationDays) public onlyOwner inState(State.inactive) {
        require(_fundingGoal > 0, "Funding goal must be greater than zero.");
        require(_durationDays > 0, "Funding duration must be greater than zero.");
        fundingGoal = _fundingGoal;
        deadline = block.timestamp + (_durationDays * 1 days);
        state = State.active;
    }
    
    function contribute() public payable inState(State.active) {
        require(msg.value > 0, "Contribution must be greater than zero.");
        require(block.timestamp < deadline, "Funding deadline has passed.");
        contributions[msg.sender] += msg.value;
        totalFundsRaised += msg.value;
    }
    
    function endFunding() public onlyOwner inState(State.active) {
        if (totalFundsRaised >= fundingGoal) {
            owner.transfer(address(this).balance);
            state = State.completed;
        } else {
            state = State.inactive;
        }
    }
    
    function withdraw() public inState(State.completed) {
        require(contributions[msg.sender] > 0, "You did not contribute to this campaign.");
        uint amount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
