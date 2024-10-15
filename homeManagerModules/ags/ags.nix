{ inputs, pkgs, lib, config, ...}: 

{
  options = {
    ags.enable = lib.mkEnableOption "enables ags hmModule";
  };

  config = lib.mkIf config.ags.enable {
    home.packages = with pkgs; let
      agsOff = pkgs.writers.writeBashBin "agsOff" ''
        systemctl --user restart ags.service
      '';
      agsOn = pkgs.writers.writeBashBin "agsOn" ''
        systemctl --user restart ags.service
      '';
    in [
      agsOff
      agsOn
    ];
    
    programs.ags = {
      enable = true;
      systemd.enable = true;

      configDir = ./.;
      extraPackages = with pkgs; [
        gtksourceview
        webkitgtk
        accountsservice
      ];
    };
  };
}
