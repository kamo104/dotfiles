#!/usr/bin/env bash

find /nix/store -mindepth 1 -maxdepth 1 -type d ! -name "*-source" ! -name "*.drv" ! -name "*-builder" ! -name "*-patches" !
 -name "*-home-manager-files" ! -name "*-home-manager-generation" ! -name "*-home-manager-path" ! -name "*-etc" ! -name ".links" ! -wholename "*
-nixos-system-*"
