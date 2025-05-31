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
      pkgs.nerd-fonts.Iosevka
      pkgs.nerd-fonts.JetBrainsMono
      pkgs.nerd-fonts.FiraCode

      # unifont
      noto-fonts-emoji
      # noto-fonts-cjk-sans
    ];

  };
  
}
