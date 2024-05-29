{ pkgs, lib, config, ...}: 

{
  options = {
    opengl.enable = lib.mkEnableOption "enables opengl";
  };
  config = lib.mkIf config.opengl.enable {
    hardware.opengl = {
      enable = true;
    	driSupport = true;
      driSupport32Bit = true;
      setLdLibraryPath = true;
      extraPackages = with pkgs; [
        vaapiVdpau
      ];
    };
  };
}
