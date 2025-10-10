# Onchain Dark Mode

A Solidity smart contract that allows users to store their dark/light mode preference onchain. Built with Foundry.

## Features

- **Theme Storage**: Store user preference for Light or Dark mode onchain
- **Toggle Functionality**: Easy toggle between themes
- **Statistics Tracking**: Track global dark mode adoption rates
- **Gas Optimized**: Efficient storage and retrieval of user preferences
- **Event Logging**: Comprehensive event emissions for frontend integration
- **Comprehensive Testing**: Full test coverage with fuzz testing

## Contract Functions

### Core Functions
- `setTheme(Theme _theme)` - Set your theme preference (Light or Dark)
- `toggleTheme()` - Toggle between light and dark mode
- `getMyTheme()` - Get your current theme preference
- `isMyDarkMode()` - Check if you prefer dark mode

### Query Functions
- `getTheme(address _user)` - Get another user's theme preference
- `isDarkMode(address _user)` - Check if a user prefers dark mode
- `getStats()` - Get global statistics (dark users, light users, total)
- `getDarkModePercentage()` - Get percentage of users preferring dark mode

## Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd onchain-dark-mode
```

2. Install dependencies:
```bash
forge install
```

3. Build the project:
```bash
forge build
```

4. Run tests:
```bash
forge test
```

## Usage

### Local Development

1. Start a local Anvil node:
```bash
anvil
```

2. Deploy to local network:
```bash
forge script script/Deploy.s.sol:DeployAnvil --rpc-url http://localhost:8545 --broadcast
```

### Testnet Deployment

1. Set up environment variables:
```bash
export PRIVATE_KEY=your_private_key
export RPC_URL=your_rpc_url
```

2. Deploy to testnet:
```bash
forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_URL --broadcast --verify
```

### Interaction Scripts

Set your contract address and interact:
```bash
export CONTRACT_ADDRESS=0x...
export PRIVATE_KEY=your_private_key

# Toggle your theme
forge script script/Deploy.s.sol:Interact --rpc-url $RPC_URL --broadcast

# Set specific theme (0 for Light, 1 for Dark)
export THEME=1
forge script script/Deploy.s.sol:SetTheme --rpc-url $RPC_URL --broadcast
```

## Contract Architecture

### State Variables
- `mapping(address => Theme) public userThemes` - Stores each user's theme preference
- `mapping(address => bool) public hasSetTheme` - Tracks if user has set a preference
- `uint256 public darkModeUsers` - Count of dark mode users
- `uint256 public lightModeUsers` - Count of light mode users

### Events
- `ThemeChanged(address indexed user, Theme newTheme, Theme previousTheme)`
- `StatsUpdated(uint256 darkModeCount, uint256 lightModeCount)`

## Testing

The project includes comprehensive tests covering:
- Basic functionality (set/get theme)
- Theme toggling
- Statistics tracking
- Edge cases and error conditions
- Fuzz testing for robustness

Run tests with verbose output:
```bash
forge test -vvv
```

Run specific test file:
```bash
forge test --match-contract OnchainDarkModeTest
```

## Gas Optimization

The contract is optimized for gas efficiency:
- Uses `uint256` for counters (cheaper than smaller types)
- Minimal storage reads/writes
- Efficient event emissions
- Optimized for common use cases

## Security Considerations

- No ownership or admin functions - fully decentralized
- No external dependencies
- Immutable once deployed
- No fund handling - purely data storage

## Frontend Integration

To integrate with a web frontend:

```javascript
// Check if user prefers dark mode
const isDarkMode = await contract.isMyDarkMode();

// Toggle theme
await contract.toggleTheme();

// Listen for theme changes
contract.on("ThemeChanged", (user, newTheme, previousTheme) => {
    if (user === currentUserAddress) {
        updateUI(newTheme === 1); // 1 = Dark, 0 = Light
    }
});

// Get global stats
const [darkCount, lightCount, totalUsers] = await contract.getStats();
const percentage = await contract.getDarkModePercentage();
```

## Foundry Commands

```bash
# Compile contracts
forge build

# Run tests
forge test

# Format code
forge fmt

# Check gas usage
forge test --gas-report

# Generate documentation
forge doc

# Clean build artifacts
forge clean

# Start local node
anvil

# Deploy script
forge script script/Deploy.s.sol --rpc-url <rpc_url> --private-key <key>
```

## License

MIT License - see LICENSE file for details.
