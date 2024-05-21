{ pkgs, lib, config, ...}: 

{
  options = {
    grub.enable = lib.mkEnableOption "enables grub";
  };

  config = lib.mkIf config.grub.enable {
    boot.loader = {
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };
}
