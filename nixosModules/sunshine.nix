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
      applications = {
        env = {};
        apps = [
          {
            name = "1080p left monitor";
            auto-detach = "true";
            prep-cmd = [
              {
                do = "${pkgs.hyprctl}/bin/hyprctl keyword monitor headless,1920x1080@60.00Hz,-1920x0,1";
                # undo = "";
              }
              {
                do = "${pkgs.hyprctl}/bin/hyprctl output create headless headless";
                undo = "${pkgs.hyprctl}/bin/hyprctl output destroy headless";
              }
            ];
          }
        ];
      };
    };
  };
}
