{ inputs, config, osConfig, pkgs, lib, ... } @args:
{
  imports = [ 
    "${args.hmModules}/common.nix"
    "${args.hmModules}/kitty/kitty.nix"
    # inputs.hyprland.homeManagerModules.default
    # "${args.hmModules}/hypr/hyprland.nix"
  ];

  # hyprlandHM.enable=true;

  common.enable = true;
  # kitty.enable = true;

  home.sessionVariables = {
    NIX_INSTALL_TYPE="PM"; # either OS or PM
    NIX_HOSTNAME="${args.hostname}";
  };

  home.username = "kgrzymkowski";
  home.homeDirectory = "/home/kgrzymkowski";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    bear
    wl-clipboard
    tshark

    # spotify
    spotify
    spotify-tray

    # python312Packages.python-lsp-server
    # python312Packages.python-lsp-ruff
  ];

  programs.fish.interactiveShellInit = 
  let
    ovpn = "sudo ${pkgs.openvpn}/bin/openvpn --config /home/kgrzymkowski/Downloads/KamilGrzymkowski.ovpn";
    ftvpn = "sudo openfortivpn";
    on = (pkgs.writers.writeBashBin "on" ''
      sudo wg-quick up wg0
      ${ovpn} &
      ${ftvpn}
    '') + "/bin/on";
    off = (pkgs.writers.writeBashBin "off" ''
      sudo wg-quick down wg0
      ${pkgs.procps}/bin/pkill -f "${ovpn}"
      ${pkgs.procps}/bin/pkill -f "${ftvpn}"
    '') + "/bin/off";

    ban = (pkgs.writers.writeBashBin "vban" '' 
      pw-cli load-module -m libpipewire-module-vban-send audio.format="S16LE" audio.rate=48000 sess.name="work-audio" destination.ip="10.100.1.2" sess.latency.msec=10 &
      pw-cli load-module -m libpipewire-module-vban-recv stream.props={audio.rate=48000 audio.format=S16LE} sess.name="work-samson" source.ip="10.100.1.2" sess.latency.msec=30
    '') + "/bin/vban";
  in ''
    alias vpnOn="${on}"
    alias vpnOff="${off}"
    alias vbanOn="${ban}"
    '';

 

  home.stateVersion = "24.05";

  # systemd.user.sessionVariables = osConfig.home-manager.users.kamo.home.sessionVariables;
}
