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
        macos_option_as_alt true
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
        map cmd+a send_key meta+a
# map cmd+b send_key meta+b
# map cmd+c send_key meta+c
# map cmd+d send_key meta+d
# map cmd+e send_key meta+e
# map cmd+f send_key meta+f
# map cmd+g send_key meta+g
# map cmd+h send_key meta+h
# map cmd+i send_key meta+i
# map cmd+j send_key meta+j
# map cmd+k send_key meta+k
# map cmd+l send_key meta+l
# map cmd+m send_key meta+m
# map cmd+n send_key meta+n
# map cmd+o send_key meta+o
# map cmd+p send_key meta+p
# map cmd+q send_key meta+q
# map cmd+r send_key meta+r
# map cmd+s send_key meta+s
# map cmd+t send_key meta+t
# map cmd+u send_key meta+u
# map cmd+v send_key meta+v
# map cmd+w send_key meta+w
# map cmd+x send_key meta+x
# map cmd+y send_key meta+y
# map cmd+z send_key meta+z
map cmd+0 send_key meta+0
map cmd+1 send_key meta+1
map cmd+2 send_key meta+2
map cmd+3 send_key meta+3
map cmd+4 send_key meta+4
map cmd+5 send_key meta+5
map cmd+6 send_key meta+6
map cmd+7 send_key meta+7
map cmd+8 send_key meta+8
map cmd+9 send_key meta+9

        # window detaching
        map ctrl+shift+d detach_tab
        map ctrl+shift+a detach_tab ask

      '';
    };
  };
}
