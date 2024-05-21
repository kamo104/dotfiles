{ pkgs, lib, config, ...}: 

{
  options = {
    rofi.enable = lib.mkEnableOption "enables rofi hmModule";
  };

  config = lib.mkIf config.rofi.enable {
    home.packages = with pkgs; [
      rofi-wayland
    ];
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      theme = ./gruvbox-dark-soft.rasi;
    };
  };
}
