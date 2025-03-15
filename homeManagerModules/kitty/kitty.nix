{ pkgs, lib, config, ...}: 

{
  options = {
    kitty.enable = lib.mkEnableOption "enables kitty hmModule";
  };

  config = lib.mkIf config.kitty.enable {
    home.packages = with pkgs; [
      kitty
    ];
    programs.kitty = {
      enable = true;
      theme = "Gruvbox Dark";
      settings = {
        font_family = "Hurmit Nerd Font";
        font_size = "14.0";
        background_opacity = "0.6";
      };
      extraConfig = ''
        tab_bar_margin_width      9
        tab_bar_margin_height     9 0
        tab_bar_style             separator
        tab_bar_min_tabs          2
        tab_separator             ""
        tab_title_template        "{fmt.fg._33271D}{fmt.bg.default}{fmt.fg._E5D6AE}{fmt.bg._33271D} {title.split()[0][-10:]} {fmt.fg._33271D}{fmt.bg.default} "
        active_tab_title_template "{fmt.fg._FFB870}{fmt.bg.default}{fmt.fg._532F06}{fmt.bg._FFB870} {title.split()[0][-10:]} {fmt.fg._FFB870}{fmt.bg.default} "

        font_size                 16.0

        # keybinds
        # macos_option_as_alt true
        # map alt+w close_tab
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
        # map alt+0 goto_tab 0
        #
        # dirty macos alt fix
        # map cmd+a send_key meta+a
        # map opt+b send_key alt+b
        # map cmd+c send_key alt+c
        # map cmd+d send_key alt+d
        # map cmd+e send_key alt+e
        # map cmd+f send_key alt+f
        # map cmd+g send_key alt+g
        # map cmd+h send_key alt+h
        # map cmd+i send_key alt+i
        # map cmd+j send_key alt+j
        # map cmd+k send_key alt+k
        # map cmd+l send_key alt+l
        # map cmd+m send_key alt+m
        # map cmd+n send_key alt+n
        # map cmd+o send_key alt+o
        # map cmd+p send_key alt+p
        # map cmd+q send_key alt+q
        # map cmd+r send_key alt+r
        # map cmd+s send_key alt+s
        # map cmd+t send_key alt+t
        # map cmd+u send_key alt+u
        # map cmd+v send_key alt+v
        # map cmd+w send_key alt+w
        # map cmd+x send_key alt+x
        # map cmd+y send_key alt+y
        # map cmd+z send_key alt+z
        map opt+1 goto_tab 1
        map opt+2 goto_tab 2
        map opt+3 goto_tab 3
        map opt+4 goto_tab 4
        map opt+5 goto_tab 5
        map opt+6 goto_tab 6
        map opt+7 goto_tab 7
        map opt+8 goto_tab 8
        map opt+9 goto_tab 9

        # window detaching
        map ctrl+shift+d detach_tab
        map ctrl+shift+a detach_tab ask

      '';
    };
  };
}
