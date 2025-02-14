require("@nomicfoundation/hardhat-toolbox");
require("./tasks/token-tasks");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    hardhat: {
      chainId: 1337
    }
  }
};
