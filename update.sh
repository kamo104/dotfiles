#!/usr/bin/env bash
ITYPE="$NIX_INSTALL_TYPE" # either OS or PM
HNAME="$NIX_HOSTNAME"

if [ -z "$ITYPE" ]; then
    echo NIX_INSTALL_TYPE is not set
    exit 1
elif [ -z "$HNAME" ]; then
    echo NIX_HOSTNAME is not set
    exit 1
fi

addgen (){
    local G=$(readlink "$PROFILE_PATH" | rev | cut -d- -f2 | rev)
    GEN=$((GEN+G))
}

if [ "$ITYPE" = "OS" ]; then
    export PROFILE_PATH="/nix/var/nix/profiles/system"
    addgen
elif [ "$ITYPE" = "PM" ]; then
    export PROFILE_PATH="$HOME/.local/state/nix/profiles/profile"
    addgen
    # export PROFILE_PATH="$HOME/.local/state/nix/profiles/home-manager"
    # addgen
fi

GEN=$((GEN+1))

MSG="$HNAME gen:$GEN"
# echo $MSG

git add --all
git commit -m "$MSG"

# if [[ -n "$(git fetch 2>&1)" ]]; then
#   echo "remote is ahead: pull, merge and push manually"
# else

if [ "$1" != "-d" ]; then
    git push
fi

if [ "$ITYPE" = "OS" ]; then
    sudo nixos-rebuild switch --flake .#"$HNAME" --install-bootloader
elif [ "$ITYPE" = "PM" ]; then
    sudo nix profile upgrade "$HNAME"
    home-manager switch --flake .#"$HNAME"
fi
