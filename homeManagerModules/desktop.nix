{ config, pkgs, lib, ... } @args:
{

  options = {
    desktop.enable = lib.mkEnableOption "enables desktop hm settings";
  };

  config = lib.mkIf config.desktop.enable {
    home.file = {
      "${config.home.homeDirectory}/Pictures" = {
        enable = true;
        target="Screenshots";
      };
      "${config.home.homeDirectory}/Pictures" = {
        enable = true;
        source = "${args.hmModules}/Wallpapers";
        recursive = true;
        target = "Wallpapers";
      };
    };
    home.packages = with pkgs; [
      qpwgraph

      firefox
      brave
      lutris
      # obs-studio
      spotify
      spotify-tray
      mumble  
      zoom-us 
      pavucontrol
      btop
      gparted
      cava
      vlc
      vcmi
      moonlight-qt
      blender
      thunderbird
      # terminal image viewer
      chafa
      # for imagemagick
      ghostscript

      libreoffice
      hunspell
      hunspellDicts.pl_PL

      nautilus
      dconf-editor
      gnome-font-viewer
      gnome-control-center
      file-roller
      gnome-disk-utility
      loupe
      gnome-network-displays

    ];
    home.sessionVariables = {
      GTK_THEME="Adwaita-dark";
      DEFAULT_BROWSER="firefox";
      GRIM_DEFAULT_DIR="${config.home.homeDirectory}/Pictures/Screenshots";
    };
    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 16;
    };
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs;[
        # obs-studio-plugins.obs-ndi
        obs-studio-plugins.obs-teleport
      ];
    };
    programs.firefox = {
      enable = true;
      # package = pkgs.firefox-beta;
      profiles = {
        kamo = {
          id = 0;
          name = "kamo";
          # userChrome = ''
          #   ${builtins.readFile ./firefox/userChrome.css}
          # '';
          # extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          #   dark-reader
          #   ublock-origin
          # ];
          settings = {
            "findbar.highlightAll" = true;
            "browser.link.open_newwindow" = 2;
            "general.autoScroll" = true;
          };
        };
      };
    };
    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          # cursor-theme = "Adwaita";
        };
        "org/freedesktop/portal/desktop" = {
          color-scheme = 1;
        };
      };
    };

    xdg.configFile = {
      "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
      "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
      "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
    };
    xdg.mimeApps = {
      enable = true;
      associations.added = {
        "x-scheme-handler/chrome"="firefox.desktop";
        "application/x-extension-htm"="firefox.desktop";
        "application/x-extension-html"="firefox.desktop";
        "application/x-extension-shtml"="firefox.desktop";
        "application/xhtml+xml"="firefox.desktop";
        "application/x-extension-xhtml"="firefox.desktop";
        "application/x-extension-xht"="firefox.desktop";

        "application/pdf" = "firefox.desktop";
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "x-scheme-handler/md" = "firefox.desktop";
      };
      defaultApplications = {
        "x-scheme-handler/chrome"="firefox.desktop";
        "application/x-extension-htm"="firefox.desktop";
        "application/x-extension-html"="firefox.desktop";
        "application/x-extension-shtml"="firefox.desktop";
        "application/xhtml+xml"="firefox.desktop";
        "application/x-extension-xhtml"="firefox.desktop";
        "application/x-extension-xht"="firefox.desktop";

        "application/pdf" = "firefox.desktop";
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "x-scheme-handler/md" = "firefox.desktop";
      };
    };
    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        # name = "Gruvbox Dark";
        package = pkgs.gnome-themes-extra;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme=1;
      };
    };

    programs.btop = {
      enable = true;
      settings = {
        color_theme = "gruvbox_dark_v2";
      };
      # extraConfig = ''${builtins.readFile ./btop/btop.conf}'';
    };
  };
}
