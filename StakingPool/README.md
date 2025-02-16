# StakingPool Project

## Overview
This project implements a staking system using Solidity smart contracts on the Ethereum blockchain. It consists of two main contracts:
- **StakeX (STX)**: An ERC20 token with minting capabilities
- **StakingPool**: A staking contract that allows users to stake STX tokens and earn rewards

### Features
- Stake STX tokens to earn rewards
- 5% annual reward rate
- Continuous reward calculation
- Secure withdrawal system
- Role-based access control
- Protection against reentrancy attacks

## Technical Requirements
- Node.js v14+ 
- npm v6+
- Hardhat
- Ethereum wallet (for deployment)
- Sepolia testnet ETH (for deployment)

## Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd stakingpool
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file in the root directory with the following variables:
```
SEPOLIA_URL=<your-sepolia-endpoint>
PRIVATE_KEY=<your-wallet-private-key>
ETHERSCAN_API_KEY=<your-etherscan-api-key>
```

## Testing

Run the test suite:
```bash
npx hardhat test
```

This will run all tests including:
- Stake functionality tests
- Unstake functionality tests
- Reward calculation tests
- Access control tests

## Deployment

To deploy the contracts to Sepolia testnet:

```bash
npx hardhat deploy --network sepolia --verify true
```

This command will:
1. Deploy both StakeX and StakingPool contracts
2. Grant MINTER_ROLE to the StakingPool contract
3. Verify the contracts on Etherscan

## Contract Addresses (Sepolia Testnet)

- StakeX Token: [0x7cc935A08D5bf17cE75a2D85D4f860d0d3386146](https://sepolia.etherscan.io/address/0x7cc935A08D5bf17cE75a2D85D4f860d0d3386146#code)
- StakingPool: [0xaf58Ae2fb541A825F2DBDE551D37B30E3ECa3E87](https://sepolia.etherscan.io/address/0xaf58Ae2fb541A825F2DBDE551D37B30E3ECa3E87#code)

## Smart Contract Details

### StakeX Token
- Name: StakeX
- Symbol: STX
- Decimals: 8
- Initial Supply: 5,000,000 STX
- Features:
  - ERC20 standard compliance
  - Minter role for reward distribution
  - Access control for secure minting

### StakingPool
- Features:
  - Secure staking mechanism
  - Accurate reward calculation (5% APY)
  - Protection against common attacks
  - Event emission for tracking
  - Custom error handling

## Security Features
- ReentrancyGuard implementation
- Role-based access control
- Custom error handling
- Secure math operations
- Protected withdrawal system

## License
UNLICENSED
