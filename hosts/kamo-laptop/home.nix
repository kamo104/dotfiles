{ inputs, config, osConfig, pkgs, lib, ... } @args:
{
  imports = [ 
    # inputs.hyprland.homeManagerModules.default
    "${args.hmModules}/hypr/hyprland.nix"

    inputs.ags.homeManagerModules.default
    "${args.hmModules}/ags/ags.nix"

    "${args.hmModules}/kitty/kitty.nix"
    "${args.hmModules}/rofi/rofi.nix"
    "${args.hmModules}/common.nix"
    "${args.hmModules}/desktop.nix"
  ];
  hyprlandHM.enable = true;
  ags.enable = true;
  kitty.enable = true;
  rofi.enable = true;

  common.enable = true;
  desktop.enable = true;

  home.sessionVariables = {
    NIX_INSTALL_TYPE="OS"; # either OS or PM
    NIX_HOSTNAME="${args.hostname}";
  };

  home.username = "kamo";
  home.homeDirectory = "/home/kamo";

  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    signal-desktop
    keepassxc

    jetbrains.idea-community
    android-studio
    # platformio
    vscode
    # transmission_4-qt6
    deluge
  ];
  systemd.user.sessionVariables = osConfig.home-manager.users.kamo.home.sessionVariables;

}
