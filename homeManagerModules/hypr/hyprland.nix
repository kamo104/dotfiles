{ pkgs, inputs, lib, config, ...}: 

{
  options = {
    hyprlandHM.enable = lib.mkEnableOption "enables hyprland hmModule";
  };
  # infinite recursion:
  # imports = lib.optionals config.hyprlandHM.enable [
  #   inputs.hyprland.homeManagerModules.default
  # ];

  config = lib.mkIf config.hyprlandHM.enable {
    nixpkgs.overlays = [
      inputs.hyprpicker.overlays.default
    ];
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      extraConfig = ''${builtins.readFile ./hyprland.conf}'';
    };
    programs.hyprlock = {
      enable = true;
      extraConfig = ''${builtins.readFile ./hyprlock.conf}'';
    };
    home.packages = with pkgs; [
      sass
      ydotool
      blueberry
      gojq
      slurp
      grim
      jq
      libnotify
      wf-recorder
      material-symbols
      hyprpicker
      playerctl
      brightnessctl

      xorg.xhost
      xorg.xprop    
    
      swww
      wl-clipboard

      gammastep
      # geoclue2
    ];
    # services.gammastep = {
    #   enable = true;
    #   provider = "geoclue2";
    # };
  };
}
