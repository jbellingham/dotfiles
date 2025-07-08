{
  # Install nix with `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install macos`
  # https://github.com/DeterminateSystems/nix-installer/issues/753

  description = "Jesse's system flake";
  # https://zero-to-nix.com/

  inputs = {
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # home-manager = {
    #   url = "github:nix-community/home-manager/release-23.11";
    #   # The `follows` keyword in inputs is used for inheritance.
    #   # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
    #   # to avoid problems caused by different versions of nixpkgs dependencies.
    #   inputs.nixpkgs.follows = "nixpkgs-darwin";
    # };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    darwin,
    # home-manager,
    ...
  }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget

      # enables installing applications that are not completely free (_any_ paid component flags it as unfree)
      nixpkgs.config.allowUnfree = true;
      # enables installing applications that don't list darwin as a supported OS
      nixpkgs.config.allowUnsupportedSystem = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Jesses-MacBook-Pro
    darwinConfigurations."Jesses-MacBook-Pro" = darwin.lib.darwinSystem {
      modules = [
          configuration
          ./modules/nix-core.nix
          ./modules/system.nix
          ./modules/apps.nix

          # home manager
          # home-manager.darwinModules.home-manager
          # {
          #   home-manager.useGlobalPkgs = true;
          #   home-manager.useUserPackages = true;
          #   # home-manager.extraSpecialArgs = specialArgs;
          #   home-manager.users.jesse = import ./home;
          # }
        ];
    };

    # users.users.jesse = {
    #   name = "Jesse";
    #   home = "/Users/jesse";
    # };

    # home-manager.users.jesse = { pkgs, ... }: {
    #   home.packages = [ pkgs.atool pkgs.httpie ];
    #   programs.bash.enable = true;

    #   # The state version is required and should stay at the version you
    #   # originally installed.
    #   home.stateVersion = "23.11";
    # };


    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Jesses-MacBook-Pro".pkgs;
  };
}
