{ pkgs, customPkgs }: 

with pkgs; [
  # helix
  (pkgs.callPackage "${customPkgs}/helix")
  vim
  wget
  fish
  fastfetch
  git
  wakeonlan
  tree
]
