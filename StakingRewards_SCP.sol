// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <=0.9.0;

import "./IERC20.sol";
contract StakingRewards{
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;  //Only owner will be able to set the duration of staking rewards and the amount for the duration

    address public owner; //This will be set when the contract is deployed when the constructor is called

    //Variable to keep track of the Rewards
    uint public duaration; //duration of the rewards
    uint public finishAt;
    uint public updateAt;
    uint public rewardRate;
    //sum of rewardrate times the duration / by the total supply
    uint public rewardPerTokenStored;
    //To keep track of the reward for tokens stored per user
    mapping(address => uint) public userRewardPerTokenPaid;
    //keeping track of rewards that the user 
    mapping(address => uint) public rewards; //address of the user

    //Variables that keep track of the total suppy of the staking token and the amount staked per user

    uint public totalSupply;
    mapping(address => uint) public balanceOf; //keep track of staking tokens //stake per user

    modifier onlyOwner (){
        require(msg.sender == owner, "not owner");
        _;
    }

    //Before implementing the function to getreward
    //By creating this modifier we will be able to track the reward per token and userRewardper token paid
    modifier updateReward(address _account) //take the input of address of the account
    {
        //Update rewardtoken stored by calling
        rewardPerTokenStored = rewardPerToken();
        //updating timestamp
        updatedAt = lastTimeRewardApplicable();  //If the reward is still ongoing then this function will return the current timestamp
        //if the duration has expired then above function will return the time when the reward has expired

        if (_account != address(0)) {
            //then update the rewards earned by this account  and call function earned(_account)
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    constructor(address _staking, address _rewardToken)
    {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken); 
    }

    //Owner of this contract will be able to set the reward for the duration //modifier
    function setRewardsDuration (uint _duration) external onlyOwner{
        //once the staking contract has died we dont want owner to be able to change the duration while the contract is still earning rewards
        //currenttimestamp > finishedtimestamp
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration; //duration from the Input
    }
    //Once the Owner sets the duration we want the owner to be able to specify the reward rate
    //The owner of this contract will be able to to call this function to send the reward tokens into this contract and set the reward
    function notifyRewardAmount (uint _amount) external  onlyOwner updateReward(address(0))//the amount of reward needs to be paid for the duration
    { 
        if(block.timestamp > finishAt)   //means the reward duration has expired or has not started
        {
            rewardRate = _amount /duration;
        }else {
            //Amount of rewards is remaining
            uint remainingRewards = rewardRate * (finishAt - block.timestamp);     //RewRate rewrads that is earned per second  .. times the amount of time that is left until the rewards ends
            rewardRate = (remainingRewards + _amount) / duration;
        }
        require(rewardRate > 0, "reward rate = 0");
        //checking enough reward to be paid out by checking the balance of the reward toekn that is lockced inside the contract 
        require(rewardRate * duration <= rewardsToken.balanceOf(address(this)), "reward amount > balance");

        //when does th reward finish
        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;

        }
    //Once the duration is set and the amount of rewards to be paid for the duration then the users can start staking to earn rewards
    //Attaching the updateReward modifier to stake
    function stake(uint _amount) external updateReward(msg.sender){
        function stake(uint _amount) external updateReward(msg.sender) //Update Rewardpertokenstoredwhen the owner of the contract calls the function notifyreward amount
        {
        require(_amount > 0, "amount = 0");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        //update the balance and total supply
        //this statevariable keeps track of amount staked by msg.sender
        balanceOf[msg.sender] += _amount;
        //this state variable keeps track of track of total amount of tokens staked inside this contract
        totalSupply += _amount;
    }
    }
    function withdraw(uint _amount) external updateReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        //tranfering token back to the caller 
        stakingToken.transfer(msg.sender, _amount);
    }

    function lastTimeRewardApplicable () public view returns (uint){
        return _(min(block.timestamp, finishAt)
    }

      function rewardPerToken() public view returns (uint) {
        if (totalSupply == 0) {
            return rewardPerTokenStored; //current rewardpertoken
        }
        return
            rewardPerTokenStored +
            (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) /
            totalSupply;
    }

    //This function calculates amount of rewards earned by the account
    
    function earned(address _account) public view returns (uint)//which takes address of the staker and returns the amount of rewards that is earned by the account
    {
         return
         //multiplying the amount of token stake timesreward per token minus user token pay
            ((balanceOf[_account] *
                (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18) +
            rewards[_account]; //previous amount of rewards earned by a user that will be stored in the mapping 
    }

    //user call this function to get the reward token
    //when the user calls this function we also recalculate rewardpertokenstored and the amount of rewards earned by the user so attach modifier 
    function getReward() external updateReward(msg.sender) {
        //the amount of rewards earned by user is stored in the mapping, mappping rewards of message.sender 
        uint reward = rewards[msg.sender];
        //transfer the reward token if 
        if (reward > 0) {
            //before transfering set the amount of rewards earned by the user 0
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }

    function _min(uint x,uint y) private pure returns (uint)
    {
        return x <= y ? x : y; 
    }
}
