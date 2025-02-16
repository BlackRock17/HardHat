const {
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { expect } = require("chai");
  
  describe("Staking System", function () {
    async function deployStakingFixture() {
      const [owner, user1] = await ethers.getSigners();
  
      // Deploy StakeX token
      const StakeX = await ethers.getContractFactory("StakeX");
      const stakeX = await StakeX.deploy();
  
      // Deploy StakingPool
      const StakingPool = await ethers.getContractFactory("StakingPool");
      const stakingPool = await StakingPool.deploy(await stakeX.getAddress());
  
      // Grant MINTER_ROLE to StakingPool
      const MINTER_ROLE = await stakeX.MINTER_ROLE();
      await stakeX.grantRole(MINTER_ROLE, await stakingPool.getAddress());
  
      // Transfer some tokens to user1 for testing
      const amount = ethers.parseUnits("1000", 8); // 1000 tokens
      await stakeX.transfer(user1.address, amount);
  
      return { stakeX, stakingPool, owner, user1 };
    }
  
    describe("Stake Functionality", function () {
      it("Should allow users to stake tokens", async function () {
        const { stakeX, stakingPool, user1 } = await loadFixture(deployStakingFixture);
        
        const stakeAmount = ethers.parseUnits("100", 8);
        await stakeX.connect(user1).approve(await stakingPool.getAddress(), stakeAmount);
        await stakingPool.connect(user1).stake(stakeAmount);
        
        expect(await stakingPool.stakedBalance(user1.address)).to.equal(stakeAmount);
      });
  
      it("Should revert when staking zero amount", async function () {
        const { stakingPool, user1 } = await loadFixture(deployStakingFixture);
        
        let failed = false;
        try {
          await stakingPool.connect(user1).stake(0);
        } catch (error) {
          failed = true;
        }
        expect(failed).to.equal(true);
      });
  
      it("Should revert when staking more than balance", async function () {
        const { stakeX, stakingPool, user1 } = await loadFixture(deployStakingFixture);
        
        const largeAmount = ethers.parseUnits("2000", 8);
        await stakeX.connect(user1).approve(await stakingPool.getAddress(), largeAmount);
        
        let failed = false;
        try {
          await stakingPool.connect(user1).stake(largeAmount);
        } catch (error) {
          failed = true;
        }
        expect(failed).to.equal(true);
      });
  
      it("Should calculate rewards correctly after staking", async function () {
        const { stakeX, stakingPool, user1 } = await loadFixture(deployStakingFixture);
        
        const stakeAmount = ethers.parseUnits("100", 8);
        await stakeX.connect(user1).approve(await stakingPool.getAddress(), stakeAmount);
        await stakingPool.connect(user1).stake(stakeAmount);
        
        // Move time forward 1 year
        await ethers.provider.send("evm_increaseTime", [365 * 24 * 60 * 60]);
        await ethers.provider.send("evm_mine");
        
        const expectedRewards = ethers.parseUnits("5", 8);
        expect(await stakingPool.calculateRewards(user1.address)).to.equal(expectedRewards);
      });
    });
  
    describe("Unstake Functionality", function () {
      it("Should allow users to unstake tokens", async function () {
        const { stakeX, stakingPool, user1 } = await loadFixture(deployStakingFixture);
        
        // First stake some tokens
        const stakeAmount = ethers.parseUnits("100", 8);
        await stakeX.connect(user1).approve(await stakingPool.getAddress(), stakeAmount);
        await stakingPool.connect(user1).stake(stakeAmount);
        
        // Then unstake half of them
        const unstakeAmount = ethers.parseUnits("50", 8);
        await stakingPool.connect(user1).unstake(unstakeAmount);
        
        expect(await stakingPool.stakedBalance(user1.address)).to.equal(stakeAmount - unstakeAmount);
      });
  
      it("Should revert when unstaking zero amount", async function () {
        const { stakingPool, user1 } = await loadFixture(deployStakingFixture);
        
        let failed = false;
        try {
          await stakingPool.connect(user1).unstake(0);
        } catch (error) {
          failed = true;
        }
        expect(failed).to.equal(true);
      });
  
      it("Should revert when unstaking more than staked", async function () {
        const { stakeX, stakingPool, user1 } = await loadFixture(deployStakingFixture);
        
        // First stake some tokens
        const stakeAmount = ethers.parseUnits("100", 8);
        await stakeX.connect(user1).approve(await stakingPool.getAddress(), stakeAmount);
        await stakingPool.connect(user1).stake(stakeAmount);
        
        // Try to unstake more than staked
        const largeAmount = ethers.parseUnits("150", 8);
        let failed = false;
        try {
          await stakingPool.connect(user1).unstake(largeAmount);
        } catch (error) {
          failed = true;
        }
        expect(failed).to.equal(true);
      });
    });
  
    describe("Claim Rewards Functionality", function () {
        it("Should allow users to claim rewards", async function () {
          const { stakeX, stakingPool, user1 } = await loadFixture(deployStakingFixture);
          
          // First stake some tokens
          const stakeAmount = ethers.parseUnits("100", 8);
          await stakeX.connect(user1).approve(await stakingPool.getAddress(), stakeAmount);
          await stakingPool.connect(user1).stake(stakeAmount);
          
          // Move time forward 1 year
          await ethers.provider.send("evm_increaseTime", [365 * 24 * 60 * 60]);
          await ethers.provider.send("evm_mine");
          
          // Get initial balance
          const initialBalance = await stakeX.balanceOf(user1.address);
          
          // Claim rewards
          await stakingPool.connect(user1).claimRewards();
          
          // Get final balance
          const finalBalance = await stakeX.balanceOf(user1.address);
    
          // Get the actual reward (difference between final and initial balance)
          const actualReward = finalBalance - initialBalance;
          
          // Expected reward is approximately 5 tokens
          const minExpectedReward = ethers.parseUnits("4.99", 8);
          const maxExpectedReward = ethers.parseUnits("5.01", 8);
          
          // Check that the reward is within acceptable range
          expect(actualReward >= minExpectedReward && actualReward <= maxExpectedReward).to.be.true;
        });
    
        it("Should revert when claiming with no rewards", async function () {
          const { stakingPool, user1 } = await loadFixture(deployStakingFixture);
          
          let failed = false;
          try {
            await stakingPool.connect(user1).claimRewards();
          } catch (error) {
            failed = true;
          }
          expect(failed).to.equal(true);
        });
    });
});