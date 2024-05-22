#!/usr/bin/env bash
GEN=$(readlink /nix/var/nix/profiles/system | cut -d- -f2)
GEN=$((GEN+1))

MSG="$(hostname) gen:$GEN"
# echo $MSG
cd /home/kamo/nixos

git add --all
git commit -m "$MSG"

if [[ -n "$(git fetch 2>&1)" ]]; then
  echo "remote is ahead: pull, merge and push manually"
else 
  # git push
fi

sudo nixos-rebuild switch --flake .#$(hostname) --install-bootloader
