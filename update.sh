#!/usr/bin/env bash
GEN=$(readlink /nix/var/nix/profiles/system | cut -d- -f2)
GEN=$((GEN+1))

MSG="$(hostname) gen:$GEN"
# echo $MSG
cd /home/kamo/nixos
git add --all
git commit -m "$MSG"
sudo nixos-rebuild switch --flake .#$(hostname) --install-bootloader
