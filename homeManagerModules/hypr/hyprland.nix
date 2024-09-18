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
    # nixpkgs.overlays = [
    #   inputs.hyprpicker.overlays.default
    # ];
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd = {
        enable = true;
        enableXdgAutostart = true;
      };
      extraConfig = ''${builtins.readFile ./hyprland.conf}'';
    };
    programs.hyprlock = {
      enable = true;
      extraConfig = ''${builtins.readFile ./hyprlock.conf}'';
    };
    services.hypridle = 
    let 
      video = "/home/kamo/Videos/out.mov";
      br-file = "/tmp/br-file";
      mpv-cmd = "${pkgs.mpv}/bin/mpv --fs --loop ${video} --hwdec=auto --taskbar-progress=no --stop-screensaver=no";

      ac-monitor = pkgs.writeShellScriptBin "ac-monitor.sh" ''
        #!/usr/bin/env bash
        dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/org/freedesktop/UPower/devices/line_power_ACAD'" | stdbuf -oL egrep "variant\ *boolean" | stdbuf -oL tr -s ' ' | stdbuf -oL cut -d ' ' -f 4 | while read boolean; do
          if [ "$boolean" = "true" ]; then
            dbus-send --session --dest=org.freedesktop.ScreenSaver --type=method_call /org/freedesktop/ScreenSaver org.freedesktop.ScreenSaver.Inhibit string:"ac-inhibit" string:"ac-connected"
          fi
        done
      '';

      on-lock = pkgs.writeShellScriptBin "on-lock.sh" ''
        #!/usr/bin/env bash
        if [ $(pgrep -f "${mpv-cmd}") ]; then
          exit 0
        fi
        ${mpv-cmd} 2>&1 &
        hyprlock
        kill %1
      '';
      br-anim = pkgs.writeShellScriptBin "br-anim.sh" ''
        #!/usr/bin/env bash
        END=$1
        STEP=$2
        if (( END - $(brightnessctl g) > 0 )); then SIGN="1"; else SIGN="-1"; fi
        while (( $SIGN * $(brightnessctl g) + STEP < END )); do
          brightnessctl s $(( $(brightnessctl g) + $SIGN * STEP ))
        done
        brightnessctl s $END
      '';
      on-resume = pkgs.writeShellScriptBin "on-resume.sh" ''
        #!/usr/bin/env bash
        BR=$(cat "${br-file}")
        rm "${br-file}"

        pkill -f "${br-anim}/bin/br-anim.sh"

        ${br-anim}/bin/br-anim.sh $BR 10 & disown
      '';
      on-pause = pkgs.writeShellScriptBin "on-pause.sh" ''
        #!/usr/bin/env bash
        if [ ! -e "${br-file}" ]; then
          brightnessctl g > "${br-file}";
        fi

        pkill -f "${br-anim}/bin/br-anim.sh"

        ${br-anim}/bin/br-anim.sh 0 2 & disown
      '';
    in
    {
      enable = true;
      settings = {
        general = {
            after_sleep_cmd = "hyprctl dispatch dpms on";
            before_sleep_cmd = "playerctl pause; loginctl lock-session";
            lock_cmd =  "${on-lock}/bin/on-lock.sh";
          };
        listener = [
          {
            timeout = 120;
            on-timeout = "${on-pause}/bin/on-pause.sh";
            on-resume = "${on-resume}/bin/on-resume.sh";
          }
          {
            timeout = 180;
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
