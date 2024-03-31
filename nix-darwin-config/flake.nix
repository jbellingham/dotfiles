{
  # Install nix with `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install macos`
  # https://github.com/DeterminateSystems/nix-installer/issues/753

  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          # https://search.nixos.org/packages
          # ---
          # cli tools
          # ---
          pkgs.bat
          pkgs.direnv
          pkgs.jump
          pkgs.oh-my-posh
          pkgs.tldr
          # pkgs.vim

        ];

      homebrew = {
        enable = true;
        brews = [
          "trash"
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

      # enables installing applications that are not completely free (_any_ paid component flags it as unfree)
      nixpkgs.config.allowUnfree = true;
      # enables installing applications that don't list darwin as a supported OS
      nixpkgs.config.allowUnsupportedSystem = true;

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # enable touch id for sudo
      security.pam.enableSudoTouchIdAuth = true;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Jesses-MacBook-Pro
    darwinConfigurations."Jesses-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Jesses-MacBook-Pro".pkgs;
  };
}
