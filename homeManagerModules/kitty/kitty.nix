{ pkgs, lib, config, ...}: 

{
  options = {
    kitty.enable = lib.mkEnableOption "enables kitty hmModule";
  };

  config = lib.mkIf config.kitty.enable {
    home.packages = with pkgs; [
      kitty
    ];
    programs.kitty = {
      enable = true;
      theme = "Gruvbox Dark";
      settings = {
        font_family = "Hurmit Nerd Font";
        font_size = "14.0";
        background_opacity = "0.6";
      };
      extraConfig = ''${builtins.readFile ./kitty.conf }'';
    };
  };
}
