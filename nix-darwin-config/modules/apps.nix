{ pkgs, ...}: {

environment.systemPackages = with pkgs;
    [
        # https://search.nixos.org/packages
        # ---
        # cli tools
        # ---
        awscli2
        bat
        darwin.trash
        fzf
        git
        jump
        jq
        lua
        oh-my-posh
        shellcheck
        tldr
        zsh-fzf-tab

        # fonts
        hack-font
        meslo-lg
        meslo-lgs-nf
        source-code-pro
    ];

    homebrew = {
        enable = true;
        taps = [
            "homebrew/cask-fonts"
        ];
        brews = [
            "direnv"
            "nowplaying-cli"
            "switchaudio-osx"
        ];
        masApps = {
            "1Password for Safari" = 1569813296;
            # "Xcode" = 497799835;
        };
        casks = [
            # ---
            # GUI Apps
            # ---
            "1password"
            "brave-browser"
            "cheatsheet"
            "dbeaver-community"
            "discord"
            "docker"
            "flux"
            "fork"
            "firefox"
            "google-chrome"
            "jetbrains-toolbox"
            "notion"
            "raycast"
            "rectangle"
            "spotify"
            "stats"
            "visual-studio-code"
            "wezterm"

            # ---
            # Fonts
            # ---
            "font-hack-nerd-font"
            "font-jetbrains-mono-nerd-font"
            "font-sf-mono"
            "font-sf-pro"
            "sf-symbols"
        ];
    };
}