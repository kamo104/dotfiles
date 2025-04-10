#!/usr/bin/env bash

if [ "$NIX_INSTALL_TYPE" = "OS" ]; then
  nix-env --delete-generations +1 --profile $HOME/.local/state/nix/profiles/home-manager
  sudo nix-env --delete-generations +1 --profile /nix/var/nix/profiles/system
elif [ "$NIX_INSTALL_TYPE" = "PM" ]; then
  sudo nix profile wipe-history
  nix profile wipe-history
elif [ "$NIX_INSTALL_TYPE" = "MAC" ]; then
  sudo nix-collect-garbage -d
fi

# run actual gc
nix store gc
# nix store optimise
