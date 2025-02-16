// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./StakeX.sol";

contract StakingPool is ReentrancyGuard {
    // State variables
    StakeX public stakeXToken;
    
    // Mapping for user's staked balance
    mapping(address => uint256) public stakedBalance;
    // Mapping for user's staking start time
    mapping(address => uint256) public stakingStartTime;
    // Mapping for user's accumulated rewards
    mapping(address => uint256) public accumulatedRewards;
    
    // Events
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);
    
    // Custom errors
    error ZeroAmount();
    error InsufficientBalance();
    error NoStakedBalance();
    error NoRewardsAccumulated();

    constructor(address _stakeXToken) {
        stakeXToken = StakeX(_stakeXToken);
    }

    function calculateRewards(address _user) public view returns (uint256) {
        if (stakedBalance[_user] == 0) return 0;
        
        // Calculate time elapsed since last stake/claim
        uint256 timeElapsed = block.timestamp - stakingStartTime[_user];
        
        // Annual rate is 5% = 0.05
        // For precise calculation: (amount * 5 * timeElapsed) / (100 * 365 days)
        return (stakedBalance[_user] * 5 * timeElapsed) / (100 * 365 days);
    }

    function stake(uint256 _amount) external nonReentrant {
        if (_amount == 0) revert ZeroAmount();
        
        // Update rewards before changing stake
        uint256 rewards = calculateRewards(msg.sender);
        accumulatedRewards[msg.sender] += rewards;
        
        // Update staking time
        stakingStartTime[msg.sender] = block.timestamp;
        
        // Update staked balance
        stakedBalance[msg.sender] += _amount;
        
        // Transfer tokens to this contract
        bool success = stakeXToken.transferFrom(msg.sender, address(this), _amount);
        if (!success) revert InsufficientBalance();
        
        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external nonReentrant {
        if (_amount == 0) revert ZeroAmount();
        if (stakedBalance[msg.sender] < _amount) revert InsufficientBalance();
        
        // Calculate and update rewards before unstaking
        uint256 rewards = calculateRewards(msg.sender);
        accumulatedRewards[msg.sender] += rewards;
        
        // Update staking time for remaining balance
        stakingStartTime[msg.sender] = block.timestamp;
        
        // Update staked balance
        stakedBalance[msg.sender] -= _amount;
        
        // Transfer tokens back to user
        bool success = stakeXToken.transfer(msg.sender, _amount);
        if (!success) revert InsufficientBalance();
        
        emit Unstaked(msg.sender, _amount);
    }
}