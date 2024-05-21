{ pkgs, lib, config, ...}: 

{
  options = {
    bluetooth.enable = lib.mkEnableOption "enables bluetooth";
  };

  config = lib.mkIf config.bluetooth.enable {
    # hardware.enableAllFirmware = true;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        Policy.AutoEnable = "true";
        General = {
          FastConnectable = "true";
          Enable = "Source,Sink,Media,Socket";
          # Disable="Headset";
        };
      };
    };
  };
  
}
