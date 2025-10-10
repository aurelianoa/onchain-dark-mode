/**
                                                  
    ▗▄▄    ▄  ▗▄▄▖ ▗▖ ▄▖     ▗▄ ▄▖ ▗▄▖ ▗▄▄  ▗▄▄▄▖
    ▐▛▀█  ▐█▌ ▐▛▀▜▌▐▌▐▛      ▐█ █▌ █▀█ ▐▛▀█ ▐▛▀▀▘
    ▐▌ ▐▌ ▐█▌ ▐▌ ▐▌▐▙█       ▐███▌▐▌ ▐▌▐▌ ▐▌▐▌   
    ▐▌ ▐▌ █ █ ▐███ ▐██       ▐▌█▐▌▐▌ ▐▌▐▌ ▐▌▐███ 
    ▐▌ ▐▌ ███ ▐▌▝█▖▐▌▐▙      ▐▌▀▐▌▐▌ ▐▌▐▌ ▐▌▐▌   
    ▐▙▄█ ▗█ █▖▐▌ ▐▌▐▌ █▖     ▐▌ ▐▌ █▄█ ▐▙▄█ ▐▙▄▄▖
    ▝▀▀  ▝▘ ▝▘▝▘ ▝▀▝▘ ▝▘     ▝▘ ▝▘ ▝▀▘ ▝▀▀  ▝▀▀▀▘
                                                                         
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title OnchainDarkMode
/// @dev A smart contract that allows users to toggle between light and dark mode preferences onchain
/// @author Aure and Claude
contract OnchainDarkMode {
    /// @dev Enum representing the theme preference
    enum Theme {
        Light,
        Dark
    }

    /// @dev Mapping from user address to their theme preference
    mapping(address => Theme) public userThemes;

    /// @dev Mapping to track if a user has set their theme preference
    mapping(address => bool) public hasSetTheme;

    /// @dev Total count of users who prefer dark mode
    uint256 public darkModeUsers;

    /// @dev Total count of users who prefer light mode
    uint256 public lightModeUsers;

    /// @dev Event emitted when a user changes their theme preference
    /// @param user The address of the user
    /// @param newTheme The new theme preference
    /// @param previousTheme The previous theme preference (if any)
    event ThemeChanged(
        address indexed user,
        Theme newTheme,
        Theme previousTheme
    );

    /// @dev Event emitted when theme statistics are updated
    /// @param darkModeCount Current number of dark mode users
    /// @param lightModeCount Current number of light mode users
    event StatsUpdated(uint256 darkModeCount, uint256 lightModeCount);

    /// @notice Sets the theme preference for the calling user
    /// @param _theme The theme preference (Light or Dark)
    function setTheme(Theme _theme) external {
        Theme previousTheme = userThemes[msg.sender];
        bool hadPreviousTheme = hasSetTheme[msg.sender];

        // Update the user's theme preference
        userThemes[msg.sender] = _theme;

        // If user hasn't set theme before, mark as set
        if (!hadPreviousTheme) {
            hasSetTheme[msg.sender] = true;
        }

        // Update counters
        _updateCounters(previousTheme, _theme, hadPreviousTheme);

        emit ThemeChanged(msg.sender, _theme, previousTheme);
        emit StatsUpdated(darkModeUsers, lightModeUsers);
    }

    /// @notice Toggles the theme preference for the calling user
    /// @dev If user has no preference set, defaults to Dark mode
    function toggleTheme() external {
        Theme currentTheme = userThemes[msg.sender];
        Theme newTheme;

        if (!hasSetTheme[msg.sender]) {
            // If user hasn't set theme, default to dark mode
            newTheme = Theme.Dark;
        } else {
            // Toggle between light and dark
            newTheme = currentTheme == Theme.Light ? Theme.Dark : Theme.Light;
        }

        // Update the user's theme preference
        Theme previousTheme = userThemes[msg.sender];
        bool hadPreviousTheme = hasSetTheme[msg.sender];

        userThemes[msg.sender] = newTheme;

        if (!hadPreviousTheme) {
            hasSetTheme[msg.sender] = true;
        }

        // Update counters
        _updateCounters(previousTheme, newTheme, hadPreviousTheme);

        emit ThemeChanged(msg.sender, newTheme, previousTheme);
        emit StatsUpdated(darkModeUsers, lightModeUsers);
    }

    /// @notice Gets the theme preference for a specific user
    /// @param _user The address of the user
    /// @return The theme preference of the user
    function getTheme(address _user) external view returns (Theme) {
        return userThemes[_user];
    }

    /// @notice Gets the theme preference for the calling user
    /// @return The theme preference of the caller
    function getMyTheme() external view returns (Theme) {
        return userThemes[msg.sender];
    }

    /// @notice Checks if a user prefers dark mode
    /// @param _user The address of the user
    /// @return True if the user prefers dark mode, false otherwise
    function isDarkMode(address _user) external view returns (bool) {
        return hasSetTheme[_user] && userThemes[_user] == Theme.Dark;
    }

    /// @notice Checks if the calling user prefers dark mode
    /// @return True if the caller prefers dark mode, false otherwise
    function isMyDarkMode() external view returns (bool) {
        return hasSetTheme[msg.sender] && userThemes[msg.sender] == Theme.Dark;
    }

    /// @notice Gets the current theme statistics
    /// @return darkCount Number of users preferring dark mode
    /// @return lightCount Number of users preferring light mode
    /// @return totalUsers Total number of users who have set a theme
    function getStats()
        external
        view
        returns (uint256 darkCount, uint256 lightCount, uint256 totalUsers)
    {
        return (darkModeUsers, lightModeUsers, darkModeUsers + lightModeUsers);
    }

    /// @notice Gets the percentage of users preferring dark mode
    /// @return Percentage (0-100) of users preferring dark mode, scaled by 100
    function getDarkModePercentage() external view returns (uint256) {
        uint256 totalUsers = darkModeUsers + lightModeUsers;
        if (totalUsers == 0) return 0;
        return (darkModeUsers * 10000) / totalUsers; // Returns percentage * 100 (e.g., 7525 = 75.25%)
    }

    /// @dev Internal function to update theme counters
    /// @param _previousTheme The user's previous theme
    /// @param _newTheme The user's new theme
    /// @param _hadPreviousTheme Whether the user had a theme set before
    function _updateCounters(
        Theme _previousTheme,
        Theme _newTheme,
        bool _hadPreviousTheme
    ) internal {
        // If user had a previous theme, decrement the old counter
        if (_hadPreviousTheme) {
            if (_previousTheme == Theme.Dark) {
                darkModeUsers--;
            } else {
                lightModeUsers--;
            }
        }

        // Increment the new counter
        if (_newTheme == Theme.Dark) {
            darkModeUsers++;
        } else {
            lightModeUsers++;
        }
    }
}
