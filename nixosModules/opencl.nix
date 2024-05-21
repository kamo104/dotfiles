{ pkgs, lib, config, ...}: 

{
  options = {
    opencl.enable = lib.mkEnableOption "enables opencl";
  };
  config = lib.mkIf config.opencl.enable {
    boot.initrd.kernelModules = [ "amdgpu" ];
    hardware.opengl = {
      enable = true;
    	driSupport = true;
      extraPackages = with pkgs; [
        # libvdpau-va-gl
        vaapiVdpau
        rocmPackages.clr.icd
      ];
    };
  };
}
