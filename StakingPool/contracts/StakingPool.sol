// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
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
        require(_amount > 0, "ZeroAmount");
        
        // Update rewards before changing stake
        uint256 rewards = calculateRewards(msg.sender);
        accumulatedRewards[msg.sender] += rewards;
        
        // Update staking time
        stakingStartTime[msg.sender] = block.timestamp;
        
        // Update staked balance
        stakedBalance[msg.sender] += _amount;
        
        // Transfer tokens to this contract
        bool success = stakeXToken.transferFrom(msg.sender, address(this), _amount);
        require(success, "InsufficientBalance");
        
        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external nonReentrant {
        require(_amount > 0, "ZeroAmount");
        require(stakedBalance[msg.sender] >= _amount, "InsufficientBalance");
        
        // Calculate and update rewards before unstaking
        uint256 rewards = calculateRewards(msg.sender);
        accumulatedRewards[msg.sender] += rewards;
        
        // Update staking time for remaining balance
        stakingStartTime[msg.sender] = block.timestamp;
        
        // Update staked balance
        stakedBalance[msg.sender] -= _amount;
        
        // Transfer tokens back to user
        bool success = stakeXToken.transfer(msg.sender, _amount);
        require(success, "InsufficientBalance");
        
        emit Unstaked(msg.sender, _amount);
    }

    function claimRewards() external nonReentrant {
        // Calculate current rewards
        uint256 currentRewards = calculateRewards(msg.sender);
        uint256 totalRewards = accumulatedRewards[msg.sender] + currentRewards;
        
        require(totalRewards > 0, "NoRewardsAccumulated");
        
        // Reset accumulated rewards and update staking time
        accumulatedRewards[msg.sender] = 0;
        stakingStartTime[msg.sender] = block.timestamp;
        
        // Mint rewards to user
        stakeXToken.mint(msg.sender, totalRewards);
        
        emit RewardsClaimed(msg.sender, totalRewards);
    }
}