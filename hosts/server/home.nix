{ inputs, config, osConfig, pkgs, lib, ... } @args:
{
  imports = [ 
    "${args.hmModules}/common.nix"
  ];

  common.enable = true;

  home.sessionVariables = {
    NIX_INSTALL_TYPE="OS"; # either OS or PM
    NIX_HOSTNAME="${args.hostname}";
  };

  home.username = "kamo";
  home.homeDirectory = "/home/kamo";

  home.packages = with pkgs; [
    # murmur
    # botamusique
    # terraria-server
  ];

  home.stateVersion = "23.11";

  systemd.user.sessionVariables = osConfig.home-manager.users.kamo.home.sessionVariables;

}
