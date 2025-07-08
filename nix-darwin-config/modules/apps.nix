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
            "FelixKratz/formulae"
            "homebrew/cask-fonts"
            "koekeishiya/formulae"
        ];
        brews = [
            "borders"
            "direnv"
            "nowplaying-cli"
            "lua"
            # brew services start sketchybar
            "sketchybar"
            "switchaudio-osx"
            "yabai"
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
            "logi-options-plus"
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