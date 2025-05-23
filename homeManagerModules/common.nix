{ config, pkgs, lib, ... } @args:
{
  options = {
    common.enable = lib.mkEnableOption "enables common hm settings";
  };

  config = lib.mkIf config.common.enable {
    home.sessionVariables = {
      SECRETS_PATH = "/home/kamo/secrets";
      EDITOR = "hx";
    };
    # home.language.base = "pl_PL.UTF-8"; 
    home.language.base = "en_US.UTF-8"; 
    home.packages = with pkgs; [
      # helix
      tmux
      ranger

      dutree
      htop
      bc
      zip
      unzip
      nil
      ffmpeg

      (pkgs.writers.writeBashBin "sendToPrinter" ''
        if [ -z "$1" ]; then
          echo "Error: No file specified to send to the printer."
          exit 1
        fi
        ${pkgs.lftp}/bin/lftp -c "set ftp:ssl-force true; set ssl:verify-certificate no; open $(cat $HOME/secrets/bambu-address); cd cache; put $1"
      '')
    ];
    programs.tmux = {
      enable = true;
      mouse = true;
      baseIndex = 1;
      clock24 = true;
      terminal = "xterm";
      escapeTime = 0;
      # newSession = true;
      prefix = "C-x";
      sensibleOnTop = false;
      extraConfig = ''
        bind c new-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"
      '';
    };
    

    # programs.direnv = {
    #   enable = true;
    #   nix-direnv.enable = true;
    # };

    programs.helix = {
      enable = true;
      defaultEditor = true;
      # package = (pkgs.callPackage "${args.customPkgs}/helix" {});
      languages = {
        language = [
        {
          name = "cpp";
          auto-format = true;
          indent = {"tab-width"=2;"unit"="  ";};
        }
        {
          name = "c";
          auto-format = true;
          indent = {"tab-width"=2;"unit"="  ";};
        }
        ];
      };
      settings = {
        theme = "gruvbox";
        editor = {
          line-number = "relative";
          lsp.display-messages = true;
          soft-wrap.enable = true;
          # inline-diagnostics.cursor-line = "warning";
        };
        keys.normal = {
          esc = [ "collapse_selection" "keep_primary_selection" ];
          p = "paste_before";
          P = "paste_after";
          # A-d = "delete_selection";
          d = "delete_selection_noyank";
          # A-c = "change_selection";
          c = "change_selection_noyank";
          "Ć" = "copy_selection_on_prev_line"; # == Alt+C (fix for MacOS polish layout)

          space = {
            w = ":w";
            q = ":q";
            "z" = '':set-option gutters.layout ["diagnostics","spacer","line-numbers","spacer","diff"]'';
            "Z" = '':set-option gutters.layout []'';
            # custom binds tooltips:
            # https://github.com/helix-editor/helix/pull/3958
            # "z: turn off zen mode" = '':set-option gutters.layout ["diagnostics","spacer","line-numbers","spacer","diff"]'';
            # "Z: turn on zen mode" = '':set-option gutters.layout []'';
          };

          # cursor position persistent after leave:
          # https://github.com/helix-editor/helix/pull/9143
          # persist-old-files = true;

          # dynamic global search:
          # https://github.com/helix-editor/helix/pull/9647
        };
      };
    };
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
        alias wakedesktop="${pkgs.wakeonlan}/bin/wakeonlan 58:11:22:bc:ec:50"
      '';
    };
  };
}
