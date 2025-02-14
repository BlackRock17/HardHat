const hre = require("hardhat");

async function main() {
  try {
    // We take contract factory
    const SimpleToken = await hre.ethers.getContractFactory("SimpleToken");
    
    // Deploy the contract
    const simpleToken = await SimpleToken.deploy();
    
    // We are waiting for the deployment to complete.
    await simpleToken.waitForDeployment();
    
    // We get the address of the deployed contract
    const tokenAddress = await simpleToken.getAddress();
    
    console.log("SimpleToken deployed to:", tokenAddress);
  } catch (error) {
    console.error("Error during deployment:", error);
    process.exit(1);
  }
}

main();