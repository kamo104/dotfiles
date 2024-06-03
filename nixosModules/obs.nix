{ pkgs, lib, config, ...}: 

{
  options = {
    obs.enable = lib.mkEnableOption "enables obs";
  };

  config = lib.mkIf config.obs.enable {
    boot.extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
      # v4l2loopback.out
    ];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="obs cam" exclusive_caps=1
    '';
    boot.kernelModules = [
      "v4l2loopback"
    ];
    security.polkit.enable = true;

    environment.systemPackages = with pkgs; [
      v4l-utils
      libcamera
      # obs-studio
      # obs-studio-plugins.obs-ndi
      # obs-studio-plugins.obs-teleport
    ];
  };
  
}
