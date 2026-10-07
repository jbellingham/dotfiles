#!/usr/bin/env bash
# macOS settings that differ from the defaults, captured from this machine on 2026-10-07.
# A key counts as non-default if it is set in its preferences domain. Values that merely equal
# the macOS default may remain. Run, then log out and in. Lines using sudo ask for your password.

osascript -e 'tell application "System Preferences" to quit' 2>/dev/null

### Global
defaults write -g AppleShowScrollBars -string WhenScrolling          # Scroll bars appear only while scrolling
defaults write -g NSDisableAutomaticTermination -bool true           # Stop macOS quitting idle apps
defaults write -g NSAutomaticCapitalizationEnabled -bool false       # No auto-capitalise
defaults write -g NSAutomaticDashSubstitutionEnabled -bool true      # Turn -- into an em dash
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false   # No double-space-to-period
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false   # No autocorrect
defaults write -g CheckSpellingWhileTyping -bool true                # Underline misspellings
defaults write -g com.apple.swipescrolldirection -bool true          # Natural scrolling
defaults write -g AppleShowAllExtensions -bool true                  # Always show file extensions
defaults write -g com.apple.springing.delay -float 0.5               # Spring-loaded folders open after 0.5s
defaults write -g AppleFontSmoothing -int 2                          # Medium font smoothing
defaults write -g AppleSpacesSwitchOnActivate -bool false            # Opening an app doesn't jump to its Space

### Security
# defaults write com.apple.LaunchServices LSQuarantine -bool false     # No "downloaded from the internet" prompt
defaults write com.apple.CrashReporter DialogType -string none       # Hide crash report dialogs
defaults write com.apple.screensaver askForPassword -bool true       # Require a password after screensaver
defaults write com.apple.screensaver askForPasswordDelay -int 0      # ...immediately
defaults write com.apple.loginwindow TALLogoutSavesState -bool false # Don't reopen apps after logout
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false  # Guest account off
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true  # Download updates automatically
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true  # Allow custom display resolutions

### Finder
defaults write com.apple.finder ShowStatusBar -bool true                    # Item count and free space at the bottom
defaults write com.apple.finder ShowPathbar -bool true                      # Folder path at the bottom
defaults write com.apple.finder ShowPreviewPane -bool false                 # No preview pane
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true          # Full path in the window title
defaults write com.apple.finder FXDefaultSearchScope -string SCcf           # Search the current folder first
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false  # No warning when renaming extensions
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv           # List view by default
defaults write com.apple.finder FK_AppCentricShowSidebar -bool true         # Show the sidebar in open/save dialogs

### Dock
defaults write com.apple.dock autohide -bool true                         # Hide the Dock until hovered
defaults write com.apple.dock tilesize -float 128                         # Icon size (128 is the maximum)
defaults write com.apple.dock launchanim -bool false                      # No bounce when opening an app
defaults write com.apple.dock mineffect -string genie                     # Genie effect on minimise
defaults write com.apple.dock minimize-to-application -bool true          # Minimise into the app's icon
defaults write com.apple.dock show-process-indicators -bool true          # Dots under running apps
defaults write com.apple.dock mouse-over-hilte-stack -bool true           # Highlight stack items on hover
defaults write com.apple.dock notification-always-show-image -bool true   # Show notification images
defaults write com.apple.dock wvous-br-corner -int 1                      # Bottom-right hot corner does nothing

### Apps
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true        # Disk Utility: debug menu
defaults write com.apple.DiskUtility DUShowEveryPartition -bool true      # Disk Utility: show every partition
defaults write com.apple.keychainaccess 'Show Expired Certificates' -bool true  # Keychain Access: show expired certs
defaults write com.apple.Terminal SecureKeyboardEntry -bool false         # Terminal: secure keyboard entry off
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true        # Activity Monitor: open the main window
defaults write com.apple.ActivityMonitor ShowCategory -int 102            # Activity Monitor: show all processes
defaults write com.apple.ActivityMonitor SelectedTab -int 0               # Activity Monitor: CPU tab
defaults write com.knollsoft.Rectangle SUHasLaunchedBefore -bool true     # Rectangle: skip first-run screen
defaults write com.knollsoft.Rectangle launchOnLogin -bool true           # Rectangle: start at login
defaults write com.knollsoft.Rectangle subsequentExecutionMode -int 1     # Rectangle: setup state

# Restart the apps that cache these settings.
killall Dock Finder SystemUIServer cfprefsd 2>/dev/null || true
