{ inputs, pkgs, lib, config, ...}: 

{
  options = {
    ags.enable = lib.mkEnableOption "enables ags hmModule";
  };

  config = lib.mkIf config.ags.enable {
    nixpkgs.overlays = [
      (final: prev: {
        # ags = inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.default;
        # ags = config.programs.ags.package;
        ags = config.programs.ags.finalPackage;
      })
    ];
    programs.ags = {
      enable = true;
      systemd.enable = true;
      # package = config.programs.ags.finalPackage;

      configDir = ./.;
      extraPackages = with pkgs; [
        gtksourceview
        webkitgtk
        accountsservice
        libdbusmenu-gtk3
      ];
    };
  };
}
