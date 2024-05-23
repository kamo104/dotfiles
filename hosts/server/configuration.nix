{ config, pkgs, inputs, ... } @args:
let
  TShock = (pkgs.callPackage "${args.customPkgs}/TShock/TShock.nix" {
    pluginsUrls = [
      {
        url="https://github.com/Moneylover3246/Crossplay/releases/download/2.2/Crossplay.dll";
        sha256="0pqqyr7897dwh4nn21jkwiilfphsf18l3qmlr4f5gg7pnrhz2ny1";
      }
    ];
  });
in
{
  imports =
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      "${args.modules}/locale.nix"
      "${args.modules}/bluetooth.nix"
      "${args.modules}/pipewire.nix"
      "${args.modules}/common.nix"
      "${args.modules}/TShock-service.nix"
    ];

  # bluetooth.enable = true;
  locale.enable = true;
  # pipewire.enable = true;
  common.enable = true;
  common.users = ["kamo"];

  services.TShock.enable = true;
  services.TShock.startCommand = ''
    ${TShock}/bin/TShock.server
  '';
  

  services.qemuGuest.enable = true;
  networking.hostName = "kamo-server";

  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/sda";
    };
  };

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "1c33c1ced078606c" "af78bf943600feb0"];
  };

  environment.systemPackages = with pkgs; [
    murmur
    botamusique
    TShock
    # terraria-server
    # (pkgs.callPackage "${args.customPkgs}/TShock/TShock.nix" {
    #   pluginsUrls = [
    #     {
    #       url="https://github.com/Moneylover3246/Crossplay/releases/download/2.2/Crossplay.dll";
    #       sha256="0pqqyr7897dwh4nn21jkwiilfphsf18l3qmlr4f5gg7pnrhz2ny1";
    #     }
    #   ];})

  ];
  home-manager = {
    extraSpecialArgs = {inherit inputs; hmModules = args.hmModules;};
    useGlobalPkgs = true;
    useUserPackages  = true;
    users.kamo = import ./home.nix;
  };

  networking.firewall.allowedTCPPorts = [ 7777 25565 64738 8181 ]; # terraria, minecraft, mumble-server, musicboty
  networking.firewall.allowedUDPPorts = [ 7777 64738 8181 ]; # terraria, mumble-server, musicbot 

  system.stateVersion = "23.11";
}
