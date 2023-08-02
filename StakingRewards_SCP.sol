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

    //Owner of this contract willbe able to set the rward for the duration
}
