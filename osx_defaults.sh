#!/usr/bin/env bash
# macOS settings that differ from the defaults, captured from this machine on 2026-10-07.
# A key counts as non-default if it is set in its preferences domain. Values that merely equal
# the macOS default may remain. Run, then log out and in. Domains under /Library need sudo.

osascript -e 'tell application "System Preferences" to quit' 2>/dev/null

# /Library/Preferences/com.apple.loginwindow
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false

# com.apple.menuextra.battery
defaults write com.apple.menuextra.battery ShowPercent -string YES

# com.apple.systemuiserver
defaults write com.apple.systemuiserver 'NSStatusItem Visible com.apple.menuextra.airport' -bool true
defaults write com.apple.systemuiserver 'NSStatusItem Visible com.apple.menuextra.appleuser' -bool true
defaults write com.apple.systemuiserver 'NSStatusItem Visible com.apple.menuextra.battery' -bool true
defaults write com.apple.systemuiserver 'NSStatusItem Visible com.apple.menuextra.bluetooth' -bool true
defaults write com.apple.systemuiserver 'NSStatusItem Visible com.apple.menuextra.volume' -bool true

# NSGlobalDomain
defaults write -g AppleShowScrollBars -string WhenScrolling
defaults write -g NSDisableAutomaticTermination -bool true
defaults write -g NSAutomaticCapitalizationEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool true
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g com.apple.swipescrolldirection -bool true
defaults write -g CheckSpellingWhileTyping -bool true
defaults write -g AppleShowAllExtensions -bool true
defaults write -g com.apple.springing.delay -float 0.5
defaults write -g AppleFontSmoothing -int 2
defaults write -g AppleSpacesSwitchOnActivate -bool false

# com.apple.LaunchServices
defaults write com.apple.LaunchServices LSQuarantine -bool false

# com.apple.CrashReporter
defaults write com.apple.CrashReporter DialogType -string none

# com.apple.DiskUtility
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility DUShowEveryPartition -bool true

# com.apple.finder
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowPreviewPane -bool false
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXDefaultSearchScope -string SCcf
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
defaults write com.apple.finder FK_AppCentricShowSidebar -bool true

# com.apple.keychainaccess
defaults write com.apple.keychainaccess 'Show Expired Certificates' -bool true

# com.apple.dock
defaults write com.apple.dock tilesize -float 128
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock mouse-over-hilte-stack -bool true
defaults write com.apple.dock show-process-indicators -bool true
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock mineffect -string genie
defaults write com.apple.dock notification-always-show-image -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock wvous-br-corner -int 1

# com.apple.loginwindow
defaults write com.apple.loginwindow TALLogoutSavesState -bool false

# com.apple.AppleMultitouchMouse
defaults write com.apple.AppleMultitouchMouse MouseButtonMode -string OneButton
defaults write com.apple.AppleMultitouchMouse MouseHorizontalScroll -bool true
defaults write com.apple.AppleMultitouchMouse MouseMomentumScroll -bool true
defaults write com.apple.AppleMultitouchMouse MouseOneFingerDoubleTapGesture -int 0
defaults write com.apple.AppleMultitouchMouse MouseTwoFingerDoubleTapGesture -int 3
defaults write com.apple.AppleMultitouchMouse MouseTwoFingerHorizSwipeGesture -int 2
defaults write com.apple.AppleMultitouchMouse MouseVerticalScroll -bool true
defaults write com.apple.AppleMultitouchMouse UserPreferences -bool true

# com.apple.AppleMultitouchTrackpad
defaults write com.apple.AppleMultitouchTrackpad Clicking -int 0
defaults write com.apple.AppleMultitouchTrackpad DragLock -int 0
defaults write com.apple.AppleMultitouchTrackpad Dragging -int 0
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 1
defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool false
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadFiveFingerPinchGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadHandResting -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadHorizScroll -int 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadMomentumScroll -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadPinch -int 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRotate -int 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadScroll -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture -int 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 3
defaults write com.apple.AppleMultitouchTrackpad USBMouseStopsTrackpad -int 0
defaults write com.apple.AppleMultitouchTrackpad UserPreferences -bool true

# com.apple.Terminal
defaults write com.apple.Terminal SecureKeyboardEntry -bool false

# com.generalarcade.flycut
defaults write com.generalarcade.flycut loadOnStartup -bool false

# com.knollsoft.Rectangle
defaults write com.knollsoft.Rectangle SUEnableAutomaticChecks -bool false
defaults write com.knollsoft.Rectangle SUHasLaunchedBefore -bool true
defaults write com.knollsoft.Rectangle launchOnLogin -bool true
defaults write com.knollsoft.Rectangle subsequentExecutionMode -int 1

# com.apple.ActivityMonitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
defaults write com.apple.ActivityMonitor ShowCategory -int 102
defaults write com.apple.ActivityMonitor SelectedTab -int 0

# /Library/Preferences/com.apple.SoftwareUpdate
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true

# com.apple.screensaver
defaults write com.apple.screensaver askForPassword -bool true
defaults write com.apple.screensaver askForPasswordDelay -int 0

# /Library/Preferences/com.apple.windowserver
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

killall Dock Finder SystemUIServer cfprefsd 2>/dev/null || true
