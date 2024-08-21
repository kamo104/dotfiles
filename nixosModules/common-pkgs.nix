{ pkgs, customPkgs }: 

with pkgs; [
  # helix
  (pkgs.callPackage "${customPkgs}/helix/default.nix")
  vim
  wget
  fish
  fastfetch
  git
  wakeonlan
  tree
]
