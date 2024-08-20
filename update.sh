#!/usr/bin/env bash
ITYPE="$NIX_INSTALL_TYPE" # either OS or PM
HNAME="$NIX_HOSTNAME"

GEN=$(readlink /nix/var/nix/profiles/system | cut -d- -f2)
GEN=$((GEN+1))

MSG="$HNAME gen:$GEN"

git add --all
git commit -m "$MSG"

# if [[ -n "$(git fetch 2>&1)" ]]; then
#   echo "remote is ahead: pull, merge and push manually"
# else

dev=false
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -d)
            dev=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if ! $dev; then
  git push
fi

if [ "$ITYPE" = "OS" ]; then
    sudo nixos-rebuild switch --flake .#"$HNAME" --install-bootloader
elif [ "$ITYPE" = "PM" ]; then
    sudo nix profile upgrade "$HNAME"
    home-manager switch --flake .#"$HNAME"
fi
