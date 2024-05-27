{ pkgs, lib, config, ...}: 

{
  options = {
    sunshine.enable = lib.mkEnableOption "enables sunshine";
  };
  config = lib.mkIf config.sunshine.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      # capSysAdmin = true;
      openFirewall = true;
    };
  };
}
