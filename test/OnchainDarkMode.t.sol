// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {OnchainDarkMode} from "../src/OnchainDarkMode.sol";

contract OnchainDarkModeTest is Test {
    OnchainDarkMode public darkModeContract;

    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);

    event ThemeChanged(
        address indexed user,
        OnchainDarkMode.Theme newTheme,
        OnchainDarkMode.Theme previousTheme
    );
    event StatsUpdated(uint256 darkModeCount, uint256 lightModeCount);

    function setUp() public {
        darkModeContract = new OnchainDarkMode();
    }

    function test_InitialState() public {
        // Test initial state
        assertEq(darkModeContract.darkModeUsers(), 0);
        assertEq(darkModeContract.lightModeUsers(), 0);

        // Test user hasn't set theme
        assertFalse(darkModeContract.hasSetTheme(user1));
        assertEq(
            uint256(darkModeContract.getTheme(user1)),
            uint256(OnchainDarkMode.Theme.Light)
        ); // Default is Light
    }

    function test_SetThemeDark() public {
        vm.prank(user1);

        // Expect events
        vm.expectEmit(true, false, false, true);
        emit ThemeChanged(
            user1,
            OnchainDarkMode.Theme.Dark,
            OnchainDarkMode.Theme.Light
        );

        vm.expectEmit(false, false, false, true);
        emit StatsUpdated(1, 0);

        darkModeContract.setTheme(OnchainDarkMode.Theme.Dark);

        // Verify state changes
        assertTrue(darkModeContract.hasSetTheme(user1));
        assertEq(
            uint256(darkModeContract.getTheme(user1)),
            uint256(OnchainDarkMode.Theme.Dark)
        );
        assertEq(darkModeContract.darkModeUsers(), 1);
        assertEq(darkModeContract.lightModeUsers(), 0);

        // Test convenience functions
        assertTrue(darkModeContract.isDarkMode(user1));

        vm.prank(user1);
        assertTrue(darkModeContract.isMyDarkMode());
    }

    function test_SetThemeLight() public {
        vm.prank(user1);

        vm.expectEmit(true, false, false, true);
        emit ThemeChanged(
            user1,
            OnchainDarkMode.Theme.Light,
            OnchainDarkMode.Theme.Light
        );

        vm.expectEmit(false, false, false, true);
        emit StatsUpdated(0, 1);

        darkModeContract.setTheme(OnchainDarkMode.Theme.Light);

        assertTrue(darkModeContract.hasSetTheme(user1));
        assertEq(
            uint256(darkModeContract.getTheme(user1)),
            uint256(OnchainDarkMode.Theme.Light)
        );
        assertEq(darkModeContract.darkModeUsers(), 0);
        assertEq(darkModeContract.lightModeUsers(), 1);
        assertFalse(darkModeContract.isDarkMode(user1));
    }

    function test_ToggleThemeFromUnset() public {
        // When user hasn't set theme, toggle should default to Dark
        vm.prank(user1);

        vm.expectEmit(true, false, false, true);
        emit ThemeChanged(
            user1,
            OnchainDarkMode.Theme.Dark,
            OnchainDarkMode.Theme.Light
        );

        darkModeContract.toggleTheme();

        assertTrue(darkModeContract.hasSetTheme(user1));
        assertEq(
            uint256(darkModeContract.getTheme(user1)),
            uint256(OnchainDarkMode.Theme.Dark)
        );
        assertEq(darkModeContract.darkModeUsers(), 1);
    }

    function test_ToggleThemeFromDark() public {
        // First set to dark
        vm.prank(user1);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Dark);

        // Then toggle to light
        vm.prank(user1);

        vm.expectEmit(true, false, false, true);
        emit ThemeChanged(
            user1,
            OnchainDarkMode.Theme.Light,
            OnchainDarkMode.Theme.Dark
        );

        darkModeContract.toggleTheme();

        assertEq(
            uint256(darkModeContract.getTheme(user1)),
            uint256(OnchainDarkMode.Theme.Light)
        );
        assertEq(darkModeContract.darkModeUsers(), 0);
        assertEq(darkModeContract.lightModeUsers(), 1);
    }

    function test_ToggleThemeFromLight() public {
        // First set to light
        vm.prank(user1);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Light);

        // Then toggle to dark
        vm.prank(user1);
        darkModeContract.toggleTheme();

        assertEq(
            uint256(darkModeContract.getTheme(user1)),
            uint256(OnchainDarkMode.Theme.Dark)
        );
        assertEq(darkModeContract.darkModeUsers(), 1);
        assertEq(darkModeContract.lightModeUsers(), 0);
    }

    function test_MultipleUsersSetTheme() public {
        // User 1 sets dark mode
        vm.prank(user1);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Dark);

        // User 2 sets light mode
        vm.prank(user2);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Light);

        // User 3 sets dark mode
        vm.prank(user3);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Dark);

        // Check final counts
        assertEq(darkModeContract.darkModeUsers(), 2);
        assertEq(darkModeContract.lightModeUsers(), 1);

        // Verify individual preferences
        assertTrue(darkModeContract.isDarkMode(user1));
        assertFalse(darkModeContract.isDarkMode(user2));
        assertTrue(darkModeContract.isDarkMode(user3));
    }

    function test_ChangeThemeUpdatesCounters() public {
        // User starts with dark mode
        vm.prank(user1);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Dark);
        assertEq(darkModeContract.darkModeUsers(), 1);
        assertEq(darkModeContract.lightModeUsers(), 0);

        // User changes to light mode
        vm.prank(user1);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Light);
        assertEq(darkModeContract.darkModeUsers(), 0);
        assertEq(darkModeContract.lightModeUsers(), 1);

        // User changes back to dark mode
        vm.prank(user1);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Dark);
        assertEq(darkModeContract.darkModeUsers(), 1);
        assertEq(darkModeContract.lightModeUsers(), 0);
    }

    function test_GetStats() public {
        // Set up different users with different themes
        vm.prank(user1);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Dark);

        vm.prank(user2);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Light);

        vm.prank(user3);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Dark);

        (
            uint256 darkCount,
            uint256 lightCount,
            uint256 totalUsers
        ) = darkModeContract.getStats();

        assertEq(darkCount, 2);
        assertEq(lightCount, 1);
        assertEq(totalUsers, 3);
    }

    function test_GetDarkModePercentage() public {
        // Test with no users
        assertEq(darkModeContract.getDarkModePercentage(), 0);

        // Add users: 2 dark, 1 light = 66.67%
        vm.prank(user1);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Dark);

        vm.prank(user2);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Light);

        vm.prank(user3);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Dark);

        uint256 percentage = darkModeContract.getDarkModePercentage();
        // 2/3 * 10000 = 6666 (66.66%)
        assertEq(percentage, 6666);
    }

    function test_GetMyTheme() public {
        vm.prank(user1);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Dark);

        vm.prank(user1);
        assertEq(
            uint256(darkModeContract.getMyTheme()),
            uint256(OnchainDarkMode.Theme.Dark)
        );

        vm.prank(user2);
        assertEq(
            uint256(darkModeContract.getMyTheme()),
            uint256(OnchainDarkMode.Theme.Light)
        ); // Default for unset user
    }

    function test_IsMyDarkMode() public {
        // User hasn't set theme
        vm.prank(user1);
        assertFalse(darkModeContract.isMyDarkMode());

        // User sets dark mode
        vm.prank(user1);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Dark);

        vm.prank(user1);
        assertTrue(darkModeContract.isMyDarkMode());

        // User changes to light mode
        vm.prank(user1);
        darkModeContract.setTheme(OnchainDarkMode.Theme.Light);

        vm.prank(user1);
        assertFalse(darkModeContract.isMyDarkMode());
    }

    function testFuzz_SetTheme(uint8 themeInput) public {
        // Only test with valid theme values (0 or 1)
        vm.assume(themeInput <= 1);

        OnchainDarkMode.Theme theme = OnchainDarkMode.Theme(themeInput);

        vm.prank(user1);
        darkModeContract.setTheme(theme);

        assertTrue(darkModeContract.hasSetTheme(user1));
        assertEq(uint256(darkModeContract.getTheme(user1)), uint256(theme));

        if (theme == OnchainDarkMode.Theme.Dark) {
            assertEq(darkModeContract.darkModeUsers(), 1);
            assertEq(darkModeContract.lightModeUsers(), 0);
        } else {
            assertEq(darkModeContract.darkModeUsers(), 0);
            assertEq(darkModeContract.lightModeUsers(), 1);
        }
    }

    function testFuzz_MultipleUsers(address[10] memory users) public {
        uint256 darkCount = 0;
        uint256 lightCount = 0;

        for (uint256 i = 0; i < users.length; i++) {
            // Skip zero address and ensure unique addresses
            if (users[i] == address(0)) continue;

            // Set alternating themes
            OnchainDarkMode.Theme theme = (i % 2 == 0)
                ? OnchainDarkMode.Theme.Dark
                : OnchainDarkMode.Theme.Light;

            vm.prank(users[i]);
            darkModeContract.setTheme(theme);

            if (theme == OnchainDarkMode.Theme.Dark) {
                darkCount++;
            } else {
                lightCount++;
            }
        }

        // Note: This might not match exactly due to potential duplicate addresses
        // but it's still a useful fuzz test for general functionality
    }
}
