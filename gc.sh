#!/usr/bin/env bash

nix-env --delete-generations +1 --profile $HOME/.local/state/nix/profiles/home-manager
sudo nix-env --delete-generations +1 --profile /nix/var/nix/profiles/system
# nix-store --gc
# nix-store --optimise
nix store gc
# nix store optimise
