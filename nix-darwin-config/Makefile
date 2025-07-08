.PHONY: default
default: update

.PHONY: update
update:
	# nix flake update updates flake inputs, e.g. nixpkgs
	# --commit-lock-file will commit changes to flake.lock
	nix flake update --commit-lock-file && \
	darwin-rebuild switch --flake .