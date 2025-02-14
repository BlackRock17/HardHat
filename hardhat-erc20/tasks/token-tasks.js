const { task } = require("hardhat/config");

task("mint-tokens", "Mints tokens to a specific address")
  .addParam("address", "The address that will receive the tokens")
  .addParam("amount", "Amount of tokens to mint")
  .setAction(async (taskArgs, hre) => {
    try {
      const SimpleToken = await hre.ethers.getContractFactory("SimpleToken");
      const simpleToken = await SimpleToken.attach("0x5FbDB2315678afecb367f032d93F642f64180aa3");

      const amount = hre.ethers.parseEther(taskArgs.amount);
      await simpleToken.mint(taskArgs.address, amount);
      
      console.log(`Minted ${taskArgs.amount} tokens to ${taskArgs.address}`);
    } catch (error) {
      console.error("Error minting tokens:", error);
    }
  });

task("transfer-tokens", "Transfers tokens between addresses")
  .addParam("to", "The address that will receive the tokens")
  .addParam("amount", "Amount of tokens to transfer")
  .setAction(async (taskArgs, hre) => {
    try {
      const SimpleToken = await hre.ethers.getContractFactory("SimpleToken");
      const simpleToken = await SimpleToken.attach("0x5FbDB2315678afecb367f032d93F642f64180aa3");

      const amount = hre.ethers.parseEther(taskArgs.amount);
      await simpleToken.transfer(taskArgs.to, amount);
      
      console.log(`Transferred ${taskArgs.amount} tokens to ${taskArgs.to}`);
    } catch (error) {
      console.error("Error transferring tokens:", error);
    }
  });

  task("check-balance", "Checks token balance for a specific address")
  .addParam("address", "The address to check balance for")
  .setAction(async (taskArgs, hre) => {
    try {
      const SimpleToken = await hre.ethers.getContractFactory("SimpleToken");
      const simpleToken = await SimpleToken.attach("0x5FbDB2315678afecb367f032d93F642f64180aa3");

      const balance = await simpleToken.balanceOf(taskArgs.address);
      const balanceInEther = hre.ethers.formatEther(balance);
      
      console.log(`Balance of ${taskArgs.address}: ${balanceInEther} STK`);
    } catch (error) {
      console.error("Error checking balance:", error);
    }
  });