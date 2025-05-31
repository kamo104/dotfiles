{ pkgs, lib, config, ...}: 

{
  options = {
    cfonts.enable = lib.mkEnableOption "enables custom fonts";
  };

  config = lib.mkIf config.cfonts.enable {
    fonts.packages = with pkgs; [
      font-awesome
      xorg.libXfont
      material-symbols
      nerd-fonts.iosevka
      nerd-fonts.jetBrainsMono
      nerd-fonts.firaCode

      # unifont
      noto-fonts-emoji
      # noto-fonts-cjk-sans
    ];

  };
  
}
