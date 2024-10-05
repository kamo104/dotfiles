{ pkgs, lib, config, ...}: 

{
  options = {
    vban.enable = lib.mkEnableOption "enables vban";
    vban.startScript = lib.mkOption {
      type = lib.types.str;
      description = "Script to be executed by the vban service";
      default = "";
    };
  };
  config = lib.mkIf config.vban.enable {
    networking.firewall.allowedUDPPorts = [ 6980 ];
    systemd.user.services.vban = {
      enable = true;
      description = "vban service";
      wants = [ "pipewire.service" ];
      after = [ "pipewire.service" ];
      # wantedBy = [ "default.target" "network.target" ];
      # wants = [ "hypridle.service" ];
      # after = [ "hypridle.service" ];
      wantedBy = [ "xdg-desktop-autostart.target" ];
      serviceConfig = {
        Restart = "always";
        RestartSec = "10s";
        StartLimitInterval = "5min";
        StartLimitBurst = 3;
      };
      script = ''
        ${config.vban.startScript}
      '';
    };
  };
}
