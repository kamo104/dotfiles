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
      # extraConfig = ''${builtins.readFile ./hyprland.conf}'';
      settings =  with builtins; with pkgs.lib.lists; 
      let
        # programs
        terminal = "${pkgs.kitty}/bin/kitty";
        fileManager = "${pkgs.nautilus}/bin/nautilus";
        programsMenu = "${pkgs.rofi-wayland}/bin/rofi -show drun";
        windowsMenu = "${pkgs.rofi-wayland}/bin/rofi -show window";
        browser = "${pkgs.firefox}/bin/firefox";
        homeAssistant = ''${specialApp} "Home Assistant" "${browser} --new-window home-assistant.kkf.internal"'';
        immich = ''${specialApp} "Immich" "${browser} --new-window immich.kkf.internal"'';
        # pwa-launch = (pkgs.writers.writeBashBin "launch" ''
        #   row=$(${pkgs.firefoxpwa}/bin/firefoxpwa profile list | grep "$1")
        #   row=''${row#* (}
        #   row=''${row%*)}
        #   ${pkgs.firefoxpwa}/bin/firefoxpwa site launch $row
        # '') + "/bin/launch";
        # jellyfin = ''${specialApp} "Jellyfin" "${pwa-launch}"'';
        jellyfin = ''${specialApp} "Jellyfin" "${browser} --new-window jellyfin.kkf.internal"'';
        messenger = "${browser} --new-window messenger.com";
        lock = "loginctl lock-session";
        ags_windows = [ "overview" "indicator0" "indicator1" "sideright" "osk" "session" "bar0" "bar1" ];
        # programs

        # scripts...
        monitorId = (pkgs.writers.writeBashBin "monitor" ''
          hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq '.["monitorID"]'
        '') + "/bin/monitor";
        currentSpecialWorkspace = (pkgs.writers.writeBashBin "workspace" ''
          hyprctl monitors -j | jq '.['`${monitorId}`']["specialWorkspace"]["name"]' -r | cut -d":" -f2
        '') + "/bin/workspace";
        random = (pkgs.writers.writeBashBin "random" ''
          head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16
        '') + "/bin/random";
        hideWindow = (pkgs.writers.writeBashBin "hide" ''
          cmd=movetoworkspacesilent
          if [ -z $1 ]; then cmd=movetoworkspace; fi
          hyprctl dispatch $cmd special:$(${random})
        '') + "/bin/hide";
        toggleFocus = (pkgs.writers.writeBashBin "focus" ''
          ags -r "App.toggleWindow(\"bar`${monitorId}`\")"
        '') + "/bin/focus";
        hideSpecial = (pkgs.writers.writeBashBin "hide" ''
          WORKSPACE=`${currentSpecialWorkspace}`
          if [ $WORKSPACE ]; then
            hyprctl dispatch togglespecialworkspace $WORKSPACE
          fi
        '') + "/bin/hide";
        # $1 == bind number
        newWorkspace = (pkgs.writers.writeBashBin "new" ''
          echo $((`${monitorId}`*10+$1+10*($1==0))) 
        '') + "/bin/new";
        # $1 == bind number
        showWorkspace = (pkgs.writers.writeBashBin "show" ''
          hyprctl dispatch workspace `${newWorkspace} $1` 
          ${hideSpecial}
        '') + "/bin/show";
        # $1 == bind number
        # $2 ? optional for silent move
        moveToWorkspace = (pkgs.writers.writeBashBin "move" ''
          cmd=movetoworkspacesilent
          if [ -z $2 ]; then cmd=movetoworkspace; fi
          hyprctl dispatch $cmd `${newWorkspace} $1`
        '') + "/bin/move";
        # $1 == window name to look for
        # $2 == the command used to start the app
        specialApp = (pkgs.writers.writeBashBin "app" ''
          N=$(hyprctl clients -j | jq '.[].tags' | grep -ni "$1" | cut -d':' -f 1)
          if [ -z $N ]; then
            hyprctl dispatch workspace special:$(${random}) #
            $2 &
            hyprctl dispatch tagwindow +"$1"
            # echo `$2 $1`
          else 
            NAME="$(hyprctl clients -j | jq '.['$(($N-1))'].workspace.name' -r)"
            NAME="''${NAME#special:}"
            hyprctl dispatch togglespecialworkspace $NAME
          fi
        '') + "/bin/app";
        # scripts

        # monitors config
        monitors = {
          "eDP-1" = {
            "workspaces"= genList (x: 1+x) 10;
            "config"="1920x1080@60.02, 0x0, 1.0";
          };
          "HDMI-A-1" = {
            "workspaces"= genList (x: 1+10+x) 10;
            "config"="1920x1080@59.94Hz, 1920x0, 1";
          };
          "headless" = {
            "workspaces" = genList (x: 1+20+x) 20;
            "config" = "1920x1080@60Hz, 0x1080, 1";
          };
        };
        # monitors config
        # binds and config:
        mainMod = "SUPER";
        specialWorkspaces = {
          "A" = "a_spec";
          "S" = "msg";
          "D" = "d_spec";
        };
        keyBinds = {
          # first row
          "TAB" = ''ags -r "App.toggleWindow('overview')"'';
          "Q" = "${terminal}";
          "W" = "${windowsMenu}";
          "E" = "${fileManager}";
          "R" = "${programsMenu}";
          # "T" = "sleep 1";
          # "Y" = "sleep 1";
          # "U" = "sleep 1";
          "I" = "${immich}";
          "O" = "hyprctl dispatch togglesplit";
          # "P" = "sleep 1";

          # second row
          # "CAPS" = "pkill ags; ags";
          "F" = "hyprctl dispatch fullscreen 0";
          # "G" = "sleep 1";
          "H" = "${homeAssistant}";
          "SHIFT H" = "${hideWindow}";
          "CONTROL H" = "${hideWindow} silent";
          "J" = "${jellyfin}";
          # "K" = "sleep 1";
          "L" = "${lock}";

          # third row
          "Z" = "${toggleFocus}";
          "X" = ''ags -r "App.toggleWindow('session')"'';
          "C" = "hyprctl dispatch killactive";
          "V" = "hyprctl dispatch togglefloating";
          "B" = "${browser}";
          "N" = "sleep 1";
          # TODO: toggle special workspace
          "M" = "${messenger}";

          "mouse_down" = "hyprctl dispatch workspace e+1";
          "mouse_up" = "hyprctl dispatch workspace e-1";
        };
      in{
        monitor = attrValues (mapAttrs (name: cfg: "${name}, ${cfg."config"}") monitors);
        exec-once = [
          # "ags"
          "${pkgs.swww}/bin/swww-daemon & sleep 1; ${pkgs.swww}/bin/swww img /home/kamo/Pictures/Wallpapers/forest.jpg"
          "sleep 10; ${pkgs.qpwgraph}/bin/qpwgraph -m"
          "[workspace special:${specialWorkspaces."S"} silent] ${pkgs.signal-desktop}/bin/signal-desktop"
          "[workspace special:browser silent] ${browser}"
          "[workspace special:k2xc silent] ${pkgs.keepassxc}/bin/keepassxc"
        ];
        xwayland = {
          force_zero_scaling = true;
        };
        input = {
          kb_layout = "pl,us";
          numlock_by_default = true;
          follow_mouse = 1;
          touchpad  = {
              natural_scroll = true;
          };
          accel_profile = "flat";
        };
        binds = {
          scroll_event_delay = 0;
          disable_keybind_grabbing = true;
        };
        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 2;
          "col.active_border" = "rgba(eae0e445)";
          "col.inactive_border" = "rgba(9a8d9533)";
          layout = "dwindle";
          allow_tearing = false;
        };
        decoration = {
          rounding = 10;
          blur = {
              enabled = true;
              size = 3;
              passes = 2;
              vibrancy = 0.1696;
          };
          drop_shadow = true;
          shadow_range = 4;
          shadow_render_power = 3;
          "col.shadow" = "rgba(1a1a1aee)";

          # blur on ags windows
          # inherit blurls;
          blurls = [] ++ ags_windows;
        };
        # blur on ags windows
        layerrule = [] ++ (map (win: "ignorealpha,${win}") ags_windows);
        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 2, myBezier"
            "windowsOut, 1, 1, default, popin 80%"
            "border, 1, 4, default"
            "borderangle, 1, 3, default"
            "fade, 1, 2, default"
            "workspaces, 1, 4, default"
            "specialWorkspace, 1, 2, default, slidefadevert"
          ];
        };
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };
        gestures = {
          workspace_swipe = true;
          workspace_swipe_forever = true;
          workspace_swipe_cancel_ratio = 0.2;
        };
        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
          # enable_swallow = true
          # swallow_regex = ^(kitty)$
        };
        workspace = 
          let 
            monWrk = mon: map (el: "${toString el}, monitor:${mon}");
          in [] ++ foldl (a: b: a++b) [] (attrValues(mapAttrs (name: cfg: monWrk name cfg."workspaces") monitors));
        bind =
          let
            SWBinds = concatLists (attrValues (mapAttrs (key: val: [
                "${mainMod}, ${key}, togglespecialworkspace, ${val}"
                "${mainMod} SHIFT, ${key}, movetoworkspace, special:${val}"
                "${mainMod} CONTROL, ${key}, movetoworkspacesilent, special:${val}"
              ]) specialWorkspaces));
            MBinds = concatLists (map (el: let FL = substring 0 1 el; in [
              "${mainMod}, ${el}, movefocus, ${FL}"
              "${mainMod} SHIFT, ${el}, movewindow, mon:${FL}"
              "${mainMod} CONTROL, ${el}, movewindow, mon:${FL} silent"
            ]) [ "left" "right" "up" "down" ]);

            genNumBinds = map (el: let els = toString el; in {
              "${els}"="${showWorkspace} ${els}";
              "SHIFT ${els}"="${moveToWorkspace} ${els}";
              "CONTROL ${els}"="${moveToWorkspace} ${els} silent";
            });
            numBinds = foldl (a: b: a // b) {} (genNumBinds (genList (x: x) 10));

            keyToBind = key: let keys = filter (el: typeOf el == "string") (split " " key); in
              ''${mainMod} ${concatStringsSep " " (take (length keys -1) keys)}, ${last keys}'';
            bindsToList = binds: attrValues (mapAttrs (key: val:
                "${keyToBind key}, exec, ${val}"
              ) binds);
            KBinds = bindsToList (keyBinds // numBinds);
          in SWBinds ++ MBinds ++ KBinds ++ [
            '', Print, exec, ${pkgs.grim}/bin/grim - | tee $GRIM_DEFAULT_DIR/$(date "+%Y%m%d_%Hh%Mm%Ss_grim.png") | wl-copy''
          ];
          bindl = [
            ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ",XF86AudioPlay, exec, playerctl play-pause"
            ",XF86AudioPrev, exec, playerctl previous"
            ",XF86AudioNext, exec, playerctl next"
            ",XF86AudioMute, exec, ags run-js 'indicator.popup(1);'"
            ",XF86AudioRaiseVolume, exec, ags run-js 'indicator.popup(1);'"
            ",XF86AudioLowerVolume, exec, ags run-js 'indicator.popup(1);'"
          ];
          bindle = [
            ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
            ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ",XF86MonBrightnessUp, exec, ags run-js 'brightness.screen_value += 0.05; indicator.popup(1);'"
            ",XF86MonBrightnessDown, exec, ags run-js 'brightness.screen_value -= 0.05; indicator.popup(1);'"
          ];
          bindm = [
            "${mainMod}, mouse:272, movewindow"
            "${mainMod}, mouse:273, resizewindow"
          ];
      };
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

      ac-monitor = pkgs.writers.writeBashBin "ac-monitor.sh" ''
        dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/org/freedesktop/UPower/devices/line_power_ACAD'" | stdbuf -oL egrep "variant\ *boolean" | stdbuf -oL tr -s ' ' | stdbuf -oL cut -d ' ' -f 4 | while read boolean; do
          if [ "$boolean" = "true" ]; then
            dbus-send --session --dest=org.freedesktop.ScreenSaver --type=method_call /org/freedesktop/ScreenSaver org.freedesktop.ScreenSaver.Inhibit string:"ac-inhibit" string:"ac-connected"
          fi
        done
      '';

      on-lock = (pkgs.writers.writeBashBin "on-lock" ''
        if [ $(pgrep -f "${mpv-cmd}") ]; then
          exit 0
        fi
        # TODO: start the video for every monitor 
        ${mpv-cmd} 2>&1 &
        ${pkgs.hyprlock}/bin/hyprlock
        kill %1
      '') + "/bin/on-lock";
      br-anim = (pkgs.writers.writeBashBin "br-anim" ''
        END=$1
        STEP=$2
        if (( END - $(${pkgs.brightnessctl}/bin/brightnessctl g) > 0 )); then SIGN="1"; else SIGN="-1"; fi
        while (( $SIGN * $(${pkgs.brightnessctl}/bin/brightnessctl g) + STEP < END )); do
          CURR=$(( $(${pkgs.brightnessctl}/bin/brightnessctl g) + $SIGN * STEP ))
          CURR="''${CURR/#-}"
          ${pkgs.brightnessctl}/bin/brightnessctl s $CURR
        done
        ${pkgs.brightnessctl}/bin/brightnessctl s $END
      '') + "/bin/br-anim";
      on-resume = (pkgs.writers.writeBashBin "on-resume" ''
        if [ -e "${br-file}" ]; then
          BR=$(cat "${br-file}")
          rm "${br-file}"
        else 
          BR=0
        fi

        ${pkgs.procps}/bin/pkill -f "${br-anim}"

        ${br-anim} $BR 10 & disown
      '') + "/bin/on-resume";
      on-pause = (pkgs.writers.writeBashBin "on-pause" ''
        if [ ! -e "${br-file}" ]; then
          ${pkgs.brightnessctl}/bin/brightnessctl g > "${br-file}";
        fi

        ${pkgs.procps}/bin/pkill -f "${br-anim}"

        ${br-anim} 0 2 & disown
      '') + "/bin/on-pause";
    in
    {
      enable = true;
      settings = {
        general = {
            after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
            before_sleep_cmd = "playerctl pause; loginctl lock-session";
            lock_cmd =  "${on-lock}";
          };
        listener = [
          {
            timeout = 60;
            on-timeout = "${on-pause}";
            on-resume = "${on-resume}";
          }
          # {
          #   timeout = 180;
          #   on-timeout = "loginctl lock-session";
          # }
          {
            timeout = 180;
            on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
            on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
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
