{ pkgs, lib, config, customPkgs, ...} @args:

let
  caCert = builtins.fetchurl {
    url = "file://${args.secrets}/ca.crt";
    sha256 = "sha256:124yzgp3b94kng50rhflxxxql0i9rq07m0rmfxixlnk6igbm9gs8";
  };
in
{
  options = {
    common.enable = lib.mkEnableOption "enables ssh, helix, git...";
    common.users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "users to configure";
    };
  };

  config = lib.mkIf config.common.enable {

    services.openssh.enable = true;
    
    # security.pki.certificateFiles = [ (/. + "${args.secrets}/ca.crt") ];
    # security.pki.certificateFiles = [ (/. + "ca.crt") ];
    security.pki.certificateFiles = [ caCert ];

    nix = {
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
      '';
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        connect-timeout = 1;
        # substituters = [
        #   "https://attic.kkf.internal/home"
        # ];
        # trusted-public-keys = [
        #   "home:aZE1fyp99MinbSsoJWgGTz1eYVsXZ93gzItBKX2kJ3o="
        # ];
        netrc-file = [
          "${args.secrets}/nix/netrc"
        ];
      };
    };
    
    nixpkgs.config.allowUnfree = true;

    networking.networkmanager.enable = true;
    console.keyMap = "pl2";

    environment.systemPackages = import "${args.modules}/common-pkgs.nix" {inherit pkgs customPkgs;};
    programs.fish.enable = true;

    users.users = lib.genAttrs config.common.users (user: {
      shell = pkgs.fish;
      isNormalUser = true;
      description = "${user}";
      extraGroups = [ "networkmanager" "wheel" "input" "video" "dialout" ];
      # packages = with pkgs; [];
    });
    
  };
}
