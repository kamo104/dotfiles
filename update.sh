#!/usr/bin/env bash
if [ -z "$NIX_INSTALL_TYPE" ]; then
    echo NIX_INSTALL_TYPE is not set
    exit 1
elif [ -z "$NIX_HOSTNAME" ]; then
    echo NIX_HOSTNAME is not set
    exit 1
fi

# addgen (){
#     local G=$(readlink "$PROFILE_PATH" | rev | cut -d- -f2 | rev)
#     GEN=$((GEN+G))
# }

if [ "$NIX_INSTALL_TYPE" = "OS" ]; then
    export PROFILE_PATH="/nix/var/nix/profiles/system"
    # addgen
elif [ "$NIX_INSTALL_TYPE" = "PM" ]; then
    export PROFILE_PATH="$HOME/.local/state/nix/profiles/profile"
    # addgen
fi

GEN=$(readlink "$PROFILE_PATH" | rev | cut -d- -f2 | rev)
GEN=$((GEN+1))
MSG="$NIX_HOSTNAME gen:$GEN"
# echo $MSG

git add --all
git commit -m "$MSG"

# if [[ -n "$(git fetch 2>&1)" ]]; then
#   echo "remote is ahead: pull, merge and push manually"
# else

if [ "$1" != "-d" ]; then
    git push
fi

if [ "$NIX_INSTALL_TYPE" = "OS" ]; then
    sudo nixos-rebuild switch --flake .#"$NIX_HOSTNAME" --install-bootloader --fallback
elif [ "$NIX_INSTALL_TYPE" = "PM" ]; then
    sudo nix profile upgrade "$NIX_HOSTNAME"
    home-manager switch --flake .#"$NIX_HOSTNAME"
fi
