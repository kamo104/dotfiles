{ inputs, config, osConfig, pkgs, lib, ... } @args:
{
  imports = [ 
    inputs.mac-app-util.homeManagerModules.default
    "${args.hmModules}/common.nix"
    "${args.hmModules}/kitty/kitty.nix"
  ];

  common.enable = true;
  kitty.enable = true;

  home.sessionVariables = {
    NIX_INSTALL_TYPE="MAC";
    NIX_HOSTNAME="${args.hostname}";
  };

  home.username = "kamo";
  home.homeDirectory = "/Users/kamo";
  programs.home-manager.enable = true;

  programs.fish = {
    interactiveShellInit = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"

    '';
  };
  

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home.packages = with pkgs; [
    # bear
    # wl-clipboard
    # tshark

    # spotify
    # spotify
    # spotify-tray

    # python312Packages.python-lsp-server
    # python312Packages.python-lsp-ruff
  ];

  home.stateVersion = "24.11";
}
