// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <=0.9.0;

import "./IERC20.sol"
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
        duration = _duration //duration from the Input

    }
    //Once the Owner sets the duration we want the owner to be able to specify the reward rate
    //The owner of this contract will be able to to call this function to send the reward tokens into this contract and set the reward
    function notifyRewardAmount (uint _amount) external  onlyOwner//the amount of reward needs to be paid for the duration
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
    function stake(uint _amount) external{}
    function withdraw(uint _amount) external {}
    function earned(address _account) external view returns (uint)//which takes address of the staker and returns the amount of rewards that is earned by the account
    {}
    function getReward () external {}
}
