{ inputs, config, osConfig, pkgs, lib, ... } @args:
{
  imports = [ 
    "${args.hmModules}/common.nix"
  ];

  common.enable = true;

  home.username = "kgrzymkowski";
  home.homeDirectory = "/home/kgrzymkowski";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # murmur
    # botamusique
    # terraria-server
    # fastfetch
  ];
  
  # helix
  # nano
  # wget
  # fish
  # fastfetch
  # git
  # wakeonlan
  # tree

  home.stateVersion = "24.05";

  # systemd.user.sessionVariables = osConfig.home-manager.users.kamo.home.sessionVariables;
}
