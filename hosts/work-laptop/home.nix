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
  kitty.enable = true;

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
    # python312Packages.python-lsp-server
    # python312Packages.python-lsp-ruff
  ];
 

  home.stateVersion = "24.05";

  # systemd.user.sessionVariables = osConfig.home-manager.users.kamo.home.sessionVariables;
}
