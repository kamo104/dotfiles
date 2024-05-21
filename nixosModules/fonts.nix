{ pkgs, lib, config, ...}: 

{
  options = {
    cfonts.enable = lib.mkEnableOption "enables custom fonts";
  };

  config = lib.mkIf config.cfonts.enable {
    fonts.packages = with pkgs; [
      font-awesome
      noto-fonts-emoji
      xorg.libXfont
      material-symbols
     (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Iosevka"  ]; })
    ];
  };
  
}
