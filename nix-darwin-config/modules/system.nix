{ pkgs, ... }:

  ###################################################################################
  #
  #  macOS's System configuration
  #
  #  All the configuration options are documented here:
  #    https://daiderd.com/nix-darwin/manual/index.html#sec-options
  #
  ###################################################################################
{

  system = {
    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    activationScripts.postUserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      dock = {
        autohide = true;

        # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.dock.wvous-bl-corner
        wvous-bl-corner = 13; # lock screen
        wvous-br-corner = null;  # disabled
        wvous-tl-corner = null;  # disabled
        wvous-tr-corner = null;  # disabled

        largesize = 64;
        magnification = true;
      };

      finder = {
        AppleShowAllFiles = true;
        ShowStatusBar = true;
      };

      screensaver.askForPasswordDelay = 10;
      CustomUserPreferences = {
        NSGlobalDomain = {
          AppleShowAllFiles = true;
          "com.apple.swipescrolldirection" = false;
          ApplePressAndHoldEnabled = true;
          
          # Add a context menu item for showing the Web Inspector in web views
          WebKitDeveloperExtras = true;
        };

        "com.apple.finder" = {
          _FXSortFoldersFirst = true;
          # When performing a search, search the current folder by default
          FXDefaultSearchScope = "SCcf";
        };

        "com.apple.LaunchServices" = {
          LSQuarantine = false;
        };

        "com.apple.screencapture" = {
          location = "~/Desktop";
          type = "png";
        };

        # "com.apple.Safari" = {
        #   # Privacy: don’t send search queries to Apple
        #   UniversalSearchEnabled = false;
        #   SuppressSearchSuggestions = true;
        #   # Press Tab to highlight each item on a web page
        #   WebKitTabToLinksPreferenceKey = true;
        #   ShowFullURLInSmartSearchField = true;
        #   # Prevent Safari from opening ‘safe’ files automatically after downloading
        #   AutoOpenSafeDownloads = false;
        #   ShowFavoritesBar = false;
        #   IncludeInternalDebugMenu = true;
        #   IncludeDevelopMenu = true;
        #   WebKitDeveloperExtrasEnabledPreferenceKey = true;
        #   WebContinuousSpellCheckingEnabled = true;
        #   WebAutomaticSpellingCorrectionEnabled = false;
        #   AutoFillFromAddressBook = false;
        #   AutoFillCreditCardData = false;
        #   AutoFillMiscellaneousForms = false;
        #   WarnAboutFraudulentWebsites = true;
        #   WebKitJavaEnabled = false;
        #   WebKitJavaScriptCanOpenWindowsAutomatically = false;
        #   # "com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks" = true;
        #   # "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
        #   # "com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled" = false;
        #   # "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled" = false;
        #   # "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles" = false;
        #   # "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically" = false;
        # };
      };
      # other macOS's defaults configuration.
      # ......
    };
  };

  fonts = {
    fontDir.enable = true;
    fonts = [
        pkgs.hack-font
        pkgs.meslo-lg
        pkgs.meslo-lgs-nf
        pkgs.source-code-pro
    ];
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh = {
    enable = true;
    enableFzfCompletion = true;
  };

  programs.vim = {
    enable = true;
    enableSensible = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  environment.shellAliases = {
    # alias rm to trash cli for safer deleting
    rm = "trash -F";
    #   rm="trashy";

    # remove file from quarantine
    unquarantine = "sudo xattr -rd com.apple.quarantine";

    # docker
    dlist = "docker ps -a && docker images";
    dps = "docker ps";
    dcb = "docker-compose build";
    dcu = "docker-compose up";
    dcd = "docker-compose down";

    # kubernetes
    k = "kubectl";
    kns = "kubens";

    # safely (moves to trash instead of immediately deleting) recursively delete all node_modules down from the call site -- uses trash cli (brew install trash)
    # -F flag asks Finder to do the trashing to allow "put back" feature
    killnm = "find . -name node_modules -type d -prune -exec trash -F {} +";

    # dotnet
    drunp = "dotnet run --project";

    cat = "bat";
    top = "btop";

    #   vim="lvim -S Session.vim";
    vim = "vim -S Session.vim";
    grep = "grep -iF --color=auto";
    tmuxa = "tmux attach";
    bu = "brew upgrade";
    dockerdebug = "docker run -ti --entrypoint sh";

    intellij = "open -na 'IntelliJ IDEA Ultimate.app'";
    goland = "open -na 'GoLand.app'";
    rebuildmac = "(cd ~/nix-darwin-config && make)";
    editmac = "(cd ~/nix-darwin-config && code .)";

    startyabai = "yabai --start-service";
    restartyabai = "yabai --restart-service"
  };
}
