//Name : Staking Token
//symbol: STT.
//Decimal : 8
//Total Supply : 500 million.
//Create a smart contract that accept this staking token for generating rewards for the user , in each 10 blocks with the compound interest of 2%.
//users can withdraw their deposit anytime and if not claimed it will be added to the principle for additional reward.
//You are safe to assume any nuances of staking and reward and please comment it in relevant code block. You may deploy any EVM based block Chain in there testnet. 
//Please send 10% of your total supply to this wallet address “0x4a78a8ac0c301D5f71Fbea7Bf797a2200403f28A”, so that we can test it in our side.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingToken {
    string public name = "Staking Token";
    string public symbol = "STT";
    uint8 public decimals = 8;
    uint256 public totalSupply = 500_000_000 * (10 ** uint256(decimals));
    
    mapping(address => uint256) private balances;
    mapping(address => uint256) private depositedBlock;
    
    // Compound interest rate: 2% (in 10 blocks)
    uint256 private compoundInterestRate = 2;
    
    // Address to which 10% of the total supply is sent
    address private rewardWallet = 0x4a78a8ac0c301D5f71Fbea7Bf797a2200403f28A;
    
    constructor() {
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
        
        // Send 10% of the total supply to the reward wallet
        uint256 rewardAmount = totalSupply / 10;
        balances[msg.sender] -= rewardAmount;
        balances[rewardWallet] = rewardAmount;
        emit Transfer(msg.sender, rewardWallet, rewardAmount);
    }
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    
    function balanceOf(address _user) external view returns (uint256) {
        return balances[_user];
    }
    
    function deposit(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        
        // Transfer tokens from the user to the contract
        balances[msg.sender] -= _amount;
        balances[address(this)] += _amount;
        depositedBlock[msg.sender] = block.number;
        
        emit Transfer(msg.sender, address(this), _amount);
        emit Deposit(msg.sender, _amount);
    }
    
    function withdraw(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= balances[address(this)], "Insufficient contract balance");
        
        uint256 depositBlock = depositedBlock[msg.sender];
        require(depositBlock > 0, "No deposit found");
        
        // Calculate the reward for the deposited amount
        uint256 rewardAmount = calculateReward(depositBlock);
        require(_amount <= rewardAmount, "Amount exceeds available reward");
        
        // Transfer tokens from the contract to the user
        balances[address(this)] -= _amount;
        balances[msg.sender] += _amount;
        
        // Update the deposit block to the current block
        depositedBlock[msg.sender] = block.number;
        
        emit Transfer(address(this), msg.sender, _amount);
        emit Withdraw(msg.sender, _amount);
    }
    
    function calculateReward(uint256 _depositBlock) private view returns (uint256) {
        uint256 blocksElapsed = block.number - _depositBlock;
        uint256 rewardAmount = (balances[address(this)] * compoundInterestRate * blocksElapsed) / (10_000 * 10 ** uint256(decimals));
        return balances[address(this)] + rewardAmount;
    }
}

