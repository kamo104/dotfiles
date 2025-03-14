{ inputs, config, osConfig, pkgs, lib, ... } @args:
{
  imports = [ 
    "${args.hmModules}/common.nix"
    "${args.hmModules}/kitty/kitty.nix"
  ];

  common.enable = true;
  kitty.enable = true;

  home.sessionVariables = {
    NIX_INSTALL_TYPE="PM"; # either OS or PM
    NIX_HOSTNAME="${args.hostname}";
  };

  home.username = "kamo";
  home.homeDirectory = "/Users/kamo";
  programs.home-manager.enable = true;

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home.packages = with pkgs; [
    # bear
    # wl-clipboard
    # tshark

    # spotify
    # spotify
    # spotify-tray

    # python312Packages.python-lsp-server
    # python312Packages.python-lsp-ruff
  ];

  # programs.fish.interactiveShellInit = 
  # let
  #   ovpn = "sudo ${pkgs.openvpn}/bin/openvpn --config /home/kgrzymkowski/Downloads/KamilGrzymkowski.ovpn";
  #   ftvpn = "sudo openfortivpn";
  #   on = (pkgs.writers.writeBashBin "on" ''
  #     sudo wg-quick up wg0
  #     ${ovpn} &
  #     ${ftvpn}
  #   '') + "/bin/on";
  #   off = (pkgs.writers.writeBashBin "off" ''
  #     sudo wg-quick down wg0
  #     ${pkgs.procps}/bin/pkill -f "${ovpn}"
  #     ${pkgs.procps}/bin/pkill -f "${ftvpn}"
  #   '') + "/bin/off";
  # in ''
  #   alias vpnOn="${on}"
  #   alias vpnOff="${off}"
  #   '';

 

  home.stateVersion = "24.05";

  # systemd.user.sessionVariables = osConfig.home-manager.users.kamo.home.sessionVariables;
}
