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
    services.hypridle = {
      enable = true;
      settings = {
        general = {
            after_sleep_cmd = "hyprctl dispatch dpms on";
            before_sleep_cmd = "playerctl pause ; loginctl lock-session";
            ignore_dbus_inhibit = false;
            lock_cmd = "${pkgs.mpv}/bin/mpv --fs --loop /home/kamo/Videos/out-run.mov & hyprlock";
            unlock_cmd = ''pkill -f -9 "${pkgs.mpv}/bin/mpv --fs --loop /home/kamo/Videos/out-run.mov"'';
          };
        listener = [
          {
            timeout = 60;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 300;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
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
      mpv # for lockscreen vid playback
    ];
    # services.gammastep = {
    #   enable = true;
    #   provider = "geoclue2";
    # };
  };
}
