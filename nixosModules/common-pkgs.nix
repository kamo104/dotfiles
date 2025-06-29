{ pkgs, customPkgs }: 

with pkgs; [
  helix
  # (pkgs.callPackage "${customPkgs}/helix" {})
  vim
  wget
  fish
  fastfetch
  # git
  tree
  killall
  (pkgs.writers.writeBashBin "wakedesktop" ''
    ${pkgs.wakeonlan}/bin/wakeonlan 58:11:22:bc:ec:50
  '')
]
