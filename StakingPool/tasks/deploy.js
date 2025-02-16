const { task, types } = require("hardhat/config");

task("deploy", "Deploys the StakeX and StakingPool contracts")
  .addOptionalParam("verify", "Verify contracts on Etherscan", false, types.boolean)
  .setAction(async (taskArgs, hre) => {
    const [deployer] = await ethers.getSigners();
    
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());

    // Deploy StakeX
    const StakeX = await ethers.getContractFactory("StakeX");
    const stakeX = await StakeX.deploy();
    await stakeX.waitForDeployment();
    const stakeXAddress = await stakeX.getAddress();
    console.log("StakeX deployed to:", stakeXAddress);

    // Deploy StakingPool
    const StakingPool = await ethers.getContractFactory("StakingPool");
    const stakingPool = await StakingPool.deploy(stakeXAddress);
    await stakingPool.waitForDeployment();
    const stakingPoolAddress = await stakingPool.getAddress();
    console.log("StakingPool deployed to:", stakingPoolAddress);

    // Grant MINTER_ROLE to StakingPool
    const MINTER_ROLE = await stakeX.MINTER_ROLE();
    const grantRoleTx = await stakeX.grantRole(MINTER_ROLE, stakingPoolAddress);
    await grantRoleTx.wait();
    console.log("MINTER_ROLE granted to StakingPool");

    // Verify contracts if requested and not on local network
    if (taskArgs.verify && network.name !== "hardhat" && network.name !== "localhost") {
      console.log("Waiting for block confirmations...");
      
      // Wait for 6 block confirmations
      const CONFIRMATIONS = 6;
      await ethers.provider.waitForBlock((await ethers.provider.getBlockNumber()) + CONFIRMATIONS);

      try {
        console.log("Verifying StakeX...");
        await hre.run("verify:verify", {
          address: stakeXAddress,
          constructorArguments: [],
        });
        
        console.log("Verifying StakingPool...");
        await hre.run("verify:verify", {
          address: stakingPoolAddress,
          constructorArguments: [stakeXAddress],
        });
        
        console.log("Verification completed successfully");
      } catch (error) {
        console.log("Verification failed:", error);
      }
    }

    // Return deployed addresses for testing purposes
    return {
      stakeX: stakeXAddress,
      stakingPool: stakingPoolAddress
    };
  });