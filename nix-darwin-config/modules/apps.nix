{ pkgs, ...}: {

environment.systemPackages = with pkgs;
    [
        # https://search.nixos.org/packages
        # ---
        # cli tools
        # ---
        ant
        awscli2
        bat
        btop
        darwin.trash
        fzf
        gh
        git
        git-extras
        jhead
        jump
        jq
        mc
        mcfly
        nodePackages."npm-check-updates"
        oh-my-posh
        shellcheck
        tldr
        zsh-fzf-tab

        # fonts
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
            "dep-tree"
            "direnv"
            "lua"
            "nowplaying-cli"
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
            "jprofiler"
            "logi-options-plus"
            "notion"
            "obsidian"
            "raycast"
            "rectangle"
            "spotify"
            "stats"
            "visual-studio-code"
            "visualvm"
            "wakatime"
            "wezterm"

            # ---
            # Fonts
            # ---
            "font-hack-nerd-font"
            "font-jetbrains-mono-nerd-font"
            "font-monaspace"
            "font-sf-mono"
            "font-sf-pro"
            "sf-symbols"
        ];
    };
}
