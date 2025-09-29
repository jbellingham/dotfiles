
{ pkgs, ... }:

{
  nix.settings = {
    # enable flakes globally
    experimental-features = ["nix-command" "flakes"];
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
  };

  nix.package = pkgs.nix;
}
