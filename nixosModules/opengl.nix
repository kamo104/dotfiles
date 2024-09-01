{ pkgs, lib, config, ...}: 

{
  options = {
    opengl.enable = lib.mkEnableOption "enables opengl";
  };
  config = lib.mkIf config.opengl.enable {
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
        vaapiIntel
      ];
    };
  };
}
