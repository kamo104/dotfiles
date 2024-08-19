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
      dutree
      htop
      bc
      zip
      unzip
      nil
      ffmpeg
    ];
    programs.tmux = {
      enable = false;
      mouse = true;
      baseIndex = 1;
      clock24 = true;
      terminal = "xterm";
      escapeTime = 0;
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
          space.w = ":w";
          space.q = ":q";
          esc = [ "collapse_selection" "keep_primary_selection" ];
          p = "paste_before";
          P = "paste_after";
          # A-d = "delete_selection";
          d = "delete_selection_noyank";
          # A-c = "change_selection";
          c = "change_selection_noyank";
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
