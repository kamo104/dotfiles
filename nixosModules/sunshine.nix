{ pkgs, lib, config, ...}: 

{
  options = {
    sunshine.enable = lib.mkEnableOption "enables sunshine";
  };
  config = lib.mkIf config.sunshine.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      settings = {
        # BUG: needs to be created even before connecting to the session
        output_name="headless";
      };
      applications = {
        env = {};
        apps = [
          {
            name = "1080p left monitor";
            auto-detach = "true";
            prep-cmd = [
              {
                do = "${pkgs.hyprland}/bin/hyprctl keyword monitor headless,1920x1080@60.00Hz,-1920x0,1";
                # undo = "";
              }
              {
                do = "${pkgs.hyprland}/bin/hyprctl output create headless headless";
                undo = "${pkgs.hyprland}/bin/hyprctl output destroy headless";
              }
            ];
          }
        ];
      };
    };
  };
}
