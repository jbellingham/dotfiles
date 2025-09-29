.PHONY: default
default: update

.PHONY: update
update:
	# nix flake update updates flake inputs, e.g. nixpkgs
	# --commit-lock-file will commit changes to flake.lock
	nix flake update --commit-lock-file && \
	darwin-rebuild switch --flake .

.PHONY: install

# One problem I had on a new install of nix after having had it installed once before on the same machine:
# warning: cannot read flake registry '/etc/nix/registry.json': error: opening file '/etc/nix/registry.json': No such file or directory
# error (ignored): error: unable to download 'https://cache.nixos.org/4q1ilwxg18vyz4p1mp7k9wv0wrycn325.narinfo': Problem with the SSL CA cert (path? access rights?) (77)
# error: unable to download 'https://cache.nixos.org/68s205iqz4x1fvry7nkhg8g270v1vcy4.narinfo': Problem with the SSL CA cert (path? access rights?) (77)
# make: *** [install] Error 1
#
# Broken symlinks in /etc/ssl/certs/ caused this. I fixed it by running:
# sudo rm /etc/ssl/certs/ca-certificates.crt
# sudo ln -s /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
install:
	# curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install macos
	nix run nix-darwin -- switch --flake ~/nix-darwin-config
	nix-channel --update