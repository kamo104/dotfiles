{ inputs, pkgs, lib, config, ...}: 

{
  options = {
    ags.enable = lib.mkEnableOption "enables ags hmModule";
  };

  config = lib.mkIf config.ags.enable {
    nixpkgs.overlays = [
      (final: prev: {
        ags = inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.default;
        # ags = config.programs.ags.package;
        # ags = config.programs.ags.finalPackage;
      })
    ];
    programs.ags = {
      enable = true;
      systemd.enable = true;

      # null or path, leave as null if you don't want hm to manage the config
      configDir = ./.;

      # additional packages to add to gjs's runtime
      extraPackages = with pkgs; [
        gtksourceview
        webkitgtk
        accountsservice
      ];
    };
  };
}
