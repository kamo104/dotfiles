{ pkgs, lib, config, ...}: 

{
  options = {
    hyprland.enable = lib.mkEnableOption "enables hyprland,sddm and theme deps";
  };

  config = lib.mkIf config.hyprland.enable {
    services.upower.enable = true;

    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    programs.hyprland.enable = true;

    # services.geoclue2.enable = true;

    services.xserver = {
      enable = true;
      xkb.layout = "pl";
      xkb.variant = "";
    };

    qt = {
      enable = true;
      platformTheme = "qt5ct";
      style = "adwaita-dark";
    };
    environment.systemPackages = with pkgs; [
      libsForQt5.qt5ct
      adwaita-qt 
      adwaita-qt6
      gnome.adwaita-icon-theme
      gnomeExtensions.appindicator
    ];
    environment.sessionVariables = {
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORMTHEME="qt5ct";
    };


    programs.dconf.enable = true;
    # services.dbus.packages = with pkgs; [ dconf ];
    # xdg.portal = {
    #   enable = true;
    #   gtkUsePortal = true;
    #   extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
    # };

    services.udev.packages = with pkgs; [ 
      gnome.gnome-settings-daemon 
    ];

    
    services.gvfs.enable = true;
    security.pam.services.sddm.enableGnomeKeyring = true;
    services.gnome.gnome-keyring.enable = true;
  };
}
