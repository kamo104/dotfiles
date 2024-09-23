#!/usr/bin/env bash

find /nix/store -mindepth 1 -maxdepth 1 -type d ! -name "*-source" ! -name "*.drv" ! -name "*-builder" ! -name "*-patches" ! -name "*-files" ! -name "*-generation" ! -name "*-path[s]*" ! -name "*-etc" ! -name ".links" ! -wholename "*-nixos-system-*" ! -name "*-fhs" ! -name "*-completions" ! -name "*-stub" ! -name "*-profile" ! -name "*-po"
