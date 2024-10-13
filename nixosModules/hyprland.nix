{ inputs, pkgs, lib, config, ...}: 

{
  options = {
    hyprland.enable = lib.mkEnableOption "enables hyprland,sddm and theme deps";
  };

  config = lib.mkIf config.hyprland.enable {
    services.upower.enable = true;

    services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
    };
    # services.displayManager.ly.enable = true;
    services.hypridle.enable = true;
    programs.hyprlock.enable = true;
    programs.hyprland.enable = true;

    # services.geoclue2.enable = true;

    services.xserver = {
      enable = true;
      xkb.layout = "pl";
      xkb.variant = "";
      # displayManager.setupCommands = ''
      #   loginctl lock-session
      # '';
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
      adwaita-icon-theme
      gnomeExtensions.appindicator
      xdg-desktop-portal-hyprland
      # libsForQt5.polkit-kde-agent
    ];
    environment.sessionVariables = {
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORMTHEME="qt5ct";
    };


    programs.dconf.enable = true;
    # services.dbus.packages = with pkgs; [ dconf hypridle ];

    services.udev.packages = with pkgs; [ 
      gnome-settings-daemon 
    ];

    
    services.gvfs.enable = true;
    security.pam.services.sddm.enableGnomeKeyring = true;
    # security.pam.services.hyprlock = {};
    services.gnome.gnome-keyring.enable = true;
  };
}
