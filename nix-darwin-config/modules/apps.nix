{ pkgs, ...}: {

environment.systemPackages = with pkgs;
    [
        # https://search.nixos.org/packages
        # ---
        # cli tools
        # ---
        bat
        # direnv
        jump
        oh-my-posh
        tldr
        zsh-fzf-tab
        # vim

    ];

    homebrew = {
        enable = true;
        brews = [
            "trash"
            "direnv"
        ];
        casks = [
            # ---
            # GUI Apps
            # ---
            "1password"
            "brave-browser"
            "cheatsheet"
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
        ];
    };
}