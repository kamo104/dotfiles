{ pkgs, lib, config, ...} @args:

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
    
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nixpkgs.config.allowUnfree = true;

    networking.networkmanager.enable = true;
    console.keyMap = "pl2";

    environment.systemPackages = import "${args.modules}/common-pkgs.nix" {inherit pkgs;};
    programs.fish.enable = true;

    users.users = lib.genAttrs config.common.users (user: {
      shell = pkgs.fish;
      isNormalUser = true;
      description = "${user}";
      extraGroups = [ "networkmanager" "wheel" "input" "video" "dialout" "nfs"];
      # packages = with pkgs; [];
    });
    
  };
}
