{ config, pkgs, lib, ... }:
{
  options = {
    common.enable = lib.mkEnableOption "enables common hm settings";
  };

  config = lib.mkIf config.common.enable {
    # home.language.base = "pl_PL.UTF-8"; 
    home.language.base = "en_US.UTF-8"; 
    home.packages = with pkgs; [
      helix
      tmux

      dutree
      htop
      bc
      zip
      unzip
      nil
      ffmpeg
    ];
    programs.tmux = {
      enable = true;
      mouse = true;
      baseIndex = 1;
      clock24 = true;
      terminal = "xterm";
      escapeTime = 0;
      extraConfig = ''
        bind c new-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"
      '';
    };
    

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    programs.helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        theme = "gruvbox";
        editor = {
          line-number = "relative";
          lsp.display-messages = true;
        };
        keys.normal = {
          esc = [ "collapse_selection" "keep_primary_selection" ];
          p = "paste_before";
          P = "paste_after";
          # A-d = "delete_selection";
          d = "delete_selection_noyank";
          # A-c = "change_selection";
          c = "change_selection_noyank";

          space = {
            w = ":w";
            q = ":q";
            "z" = '':set-option gutters.layout ["diagnostics","spacer","line-numbers","spacer","diff"]'';
            "Z" = '':set-option gutters.layout []'';
          };
          # custom binds tooltips:
          # https://github.com/helix-editor/helix/pull/3958
          # "z: turn off zen mode" = '':set-option gutters.layout ["diagnostics","spacer","line-numbers","spacer","diff"]'';
          # "Z: turn on zen mode" = '':set-option gutters.layout []'';

          # cursor position persistent after leave:
          # https://github.com/helix-editor/helix/pull/9143
          # persist-old-files = true

          # dynamic global search:
          # https://github.com/helix-editor/helix/pull/9647
        };
      };
    };
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
        alias wakedesktop="wakeonlan 58:11:22:bc:ec:50"
      '';
    };
  };
}
