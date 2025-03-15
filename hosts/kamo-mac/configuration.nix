{ config, pkgs, inputs, ... } @args:
{
  imports =
    [
      inputs.home-manager.darwinModules.home-manager
    ];

  nixpkgs.hostPlatform = pkgs.lib.mkDefault "aarch64-darwin";

  services.nix-daemon.enable = true;
  nix = {
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      connect-timeout = 1;
    };
  };

  
  security.pam.enableSudoTouchIdAuth = true;

  programs.fish.enable = true;
  users.users.kamo = {
    home = "/Users/kamo";
    shell = pkgs.fish;
  };
  system.stateVersion = 5;

  home-manager = {
    extraSpecialArgs = {inherit inputs; hmModules = args.hmModules; hostname = args.hostname; secrets = args.secrets; customPkgs = args.customPkgs;};
    useGlobalPkgs = true;
    useUserPackages  = true;
    users.kamo = import ./home.nix;
  };
    

  # networking.wg-quick.interfaces = {
  #   wg0 = {
  #     autostart = false;
  #     address = [ "10.100.1.2/32" ];
  #     listenPort = 42069;
  #     privateKeyFile = "${args.secrets}/wg-keys/internal/private";
  #     dns = ["10.100.0.1" "~kkf.internal"];
  #     postUp = ''
  #       ${pkgs.systemd}/bin/resolvectl domain wg0 '~kkf.internal'
  #     '';
  #     peers = [
  #       {
  #         publicKey = "oT6pJKSYRfosjzNQ9nUNQiDDyDzZylVCCJ8ePNXwX0Y=";
  #         allowedIPs = [ "10.100.0.0/16" ];
  #         endpoint = "grzymoserver.duckdns.org:42069";
  #         persistentKeepalive = 25;
  #       }
  #     ];
  #   };
  #   wg1 = {
  #     autostart = false;
  #     address = [ "10.100.1.2/32" ];
  #     listenPort = 42069;
  #     privateKeyFile = "${args.secrets}/wg-keys/internal/private";
  #     dns = ["10.100.0.1"];
  #     peers = [
  #       {
  #         publicKey = "oT6pJKSYRfosjzNQ9nUNQiDDyDzZylVCCJ8ePNXwX0Y=";
  #         allowedIPs = [ "0.0.0.0/0" ];
  #         endpoint = "grzymoserver.duckdns.org:42069";
  #         persistentKeepalive = 25;
  #       }
  #     ];
  #   };
  # };
}
