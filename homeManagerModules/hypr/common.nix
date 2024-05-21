{ pkgs, lib, config, ...}: 

{
  options = {
    hyprland.enable = lib.mkEnableOption "enables hyprland hmModule";
    # common.users = lib.mkOption {
    #   type = lib.types.listOf lib.types.str;
    #   default = [];
    #   description = "users to configure";
    # };
  };

  config = lib.mkIf config.hyprland.enable {
    
  };
}
