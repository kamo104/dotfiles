{ pkgs, lib, config, ...}: 

{
  options = {
    kitty.enable = lib.mkEnableOption "enables kitty hmModule";
  };

  config = lib.mkIf config.kitty.enable {

    programs.fish = {
      # enable = true;
      interactiveShellInit = ''
        alias kssh="${pkgs.kitty}/bin/kitten ssh"
      '';
    };
    home.packages = with pkgs; [
      kitty
    ];
    programs.kitty = {
      enable = true;
      theme = "Gruvbox Dark";
      settings = {
        font_family = "Hurmit Nerd Font";
        font_size = "20.0";
        background_opacity = "0.6";
        background_blur = 50;
      };
      extraConfig = ''
        tab_bar_margin_width      9
        tab_bar_margin_height     9 0
        tab_bar_style             separator
        tab_bar_min_tabs          2
        tab_separator             ""
        tab_title_template        "{fmt.fg._33271D}{fmt.bg.default}{fmt.fg._E5D6AE}{fmt.bg._33271D} {title.split()[0][-10:]} {fmt.fg._33271D}{fmt.bg.default} "
        active_tab_title_template "{fmt.fg._FFB870}{fmt.bg.default}{fmt.fg._532F06}{fmt.bg._FFB870} {title.split()[0][-10:]} {fmt.fg._FFB870}{fmt.bg.default} "

        # keybinds
        # macos_cmd_as_alt true
        map ctrl+t new_tab_with_cwd
        map alt+1 goto_tab 1
        map alt+2 goto_tab 2
        map alt+3 goto_tab 3
        map alt+4 goto_tab 4
        map alt+5 goto_tab 5
        map alt+6 goto_tab 6
        map alt+7 goto_tab 7
        map alt+8 goto_tab 8
        map alt+9 goto_tab 9

        
        map cmd+1 goto_tab 1
        map cmd+2 goto_tab 2
        map cmd+3 goto_tab 3
        map cmd+4 goto_tab 4
        map cmd+5 goto_tab 5
        map cmd+6 goto_tab 6
        map cmd+7 goto_tab 7
        map cmd+8 goto_tab 8
        map cmd+9 goto_tab 9

        # window detaching
        map ctrl+shift+d detach_tab
        map ctrl+shift+a detach_tab ask
      '';
    };
  };
}
