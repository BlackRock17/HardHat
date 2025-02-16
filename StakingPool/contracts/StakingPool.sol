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
}