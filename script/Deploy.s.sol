// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {OnchainDarkMode} from "../src/OnchainDarkMode.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        OnchainDarkMode darkModeContract = new OnchainDarkMode();

        console.log("OnchainDarkMode deployed to:", address(darkModeContract));

        vm.stopBroadcast();
    }
}

contract DeployAnvil is Script {
    function setUp() public {}

    function run() public {
        // Use default anvil account private key for local deployment
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

        vm.startBroadcast(deployerPrivateKey);

        OnchainDarkMode darkModeContract = new OnchainDarkMode();

        console.log("OnchainDarkMode deployed to:", address(darkModeContract));
        console.log("Deployer address:", vm.addr(deployerPrivateKey));

        // Demonstrate functionality by setting some initial themes
        console.log("\n--- Demonstrating functionality ---");

        // Set deployer's theme to dark mode
        darkModeContract.setTheme(OnchainDarkMode.Theme.Dark);
        console.log("Deployer set theme to Dark mode");

        // Log initial stats
        (
            uint256 darkCount,
            uint256 lightCount,
            uint256 totalUsers
        ) = darkModeContract.getStats();
        console.log("Stats - Dark:", darkCount);
        console.log("Light:", lightCount);
        console.log("Total:", totalUsers);

        vm.stopBroadcast();
    }
}

contract Interact is Script {
    OnchainDarkMode public darkModeContract;

    function setUp() public {
        // Replace with your deployed contract address
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        darkModeContract = OnchainDarkMode(contractAddress);
    }

    function run() public {
        uint256 userPrivateKey = vm.envUint("PRIVATE_KEY");
        address user = vm.addr(userPrivateKey);

        vm.startBroadcast(userPrivateKey);

        console.log("Current user:", user);
        console.log("Current theme:", uint256(darkModeContract.getMyTheme()));
        console.log("Has set theme:", darkModeContract.hasSetTheme(user));
        console.log("Is dark mode:", darkModeContract.isMyDarkMode());

        // Toggle theme
        console.log("\nToggling theme...");
        darkModeContract.toggleTheme();

        console.log("New theme:", uint256(darkModeContract.getMyTheme()));
        console.log("Is dark mode:", darkModeContract.isMyDarkMode());

        // Show updated stats
        (
            uint256 darkCount,
            uint256 lightCount,
            uint256 totalUsers
        ) = darkModeContract.getStats();
        console.log("\nUpdated Stats:");
        console.log("Dark mode users:", darkCount);
        console.log("Light mode users:", lightCount);
        console.log("Total users:", totalUsers);
        uint256 percentage = darkModeContract.getDarkModePercentage();
        console.log("Dark mode percentage:", percentage / 100);
        console.log("Decimal part:", percentage % 100);

        vm.stopBroadcast();
    }
}

contract SetTheme is Script {
    OnchainDarkMode public darkModeContract;

    function setUp() public {
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        darkModeContract = OnchainDarkMode(contractAddress);
    }

    function run() public {
        uint256 userPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 themeChoice = vm.envUint("THEME"); // 0 for Light, 1 for Dark

        require(
            themeChoice <= 1,
            "Invalid theme choice. Use 0 for Light, 1 for Dark"
        );

        OnchainDarkMode.Theme theme = OnchainDarkMode.Theme(themeChoice);

        vm.startBroadcast(userPrivateKey);

        console.log("Setting theme to:", themeChoice == 0 ? "Light" : "Dark");
        darkModeContract.setTheme(theme);

        console.log("Theme set successfully!");
        console.log("Current theme:", uint256(darkModeContract.getMyTheme()));

        vm.stopBroadcast();
    }
}
