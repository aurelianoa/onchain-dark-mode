# Onchain Dark Mode Project - Copilot Instructions

This is a Foundry-based Solidity smart contract project for implementing an onchain dark mode system.

## Project Structure
- `src/` - Smart contract source files
- `test/` - Test files using Foundry's testing framework
- `script/` - Deployment and interaction scripts
- `foundry.toml` - Foundry configuration file

## Key Components
- **OnchainDarkMode.sol** - Main smart contract implementing dark mode toggle functionality
- **OnchainDarkMode.t.sol** - Test suite for the dark mode contract
- **Deploy.s.sol** - Deployment script

## Development Guidelines
- Use Foundry for building, testing, and deploying
- Follow Solidity best practices and security patterns
- Write comprehensive tests for all functionality
- Use events for important state changes
- Implement proper access controls where needed

## Commands
- `forge build` - Compile contracts
- `forge test` - Run tests
- `forge script` - Run deployment scripts
- `forge fmt` - Format code
- `forge install` - Install dependencies