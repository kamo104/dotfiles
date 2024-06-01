{ config, pkgs, inputs, ... } @args:
let
  TShock = (pkgs.callPackage "${args.customPkgs}/TShock/TShock.nix" {
    pluginsUrls = [
      {
        url="https://github.com/Moneylover3246/Crossplay/releases/download/2.2/Crossplay.dll";
        sha256="0pqqyr7897dwh4nn21jkwiilfphsf18l3qmlr4f5gg7pnrhz2ny1";
      }
      {
        url="https://github.com/Pryaxis/Vanillafier/blob/master/Vanillafier/build/Vanillafier.dll";
        sha256="0p9ppzh8v6r9bcgsvcd0qp8akgip082km7rhwhibil14rnbsp931";
      }
      {
        url="https://github.com/TerraTrapezium/AutoTeam/releases/download/v1.0.0/AutoTeam.dll";
        sha256="1wv502d82rmrb7qs0sapjawyjwr61mvng2pwxc79rv5x17246ml0";
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
  users.users.kamo.linger = true;

  services.TShock.enable = true;
  services.TShock.startCommand = ''
    ${TShock}/bin/TShock.Server -world /home/kamo/.local/share/Terraria/Worlds/Niebiański_Rubież_Harpii.wld
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
  ];
  home-manager = {
    extraSpecialArgs = {inherit inputs; hmModules = args.hmModules;};
    useGlobalPkgs = true;
    useUserPackages  = true;
    users.kamo = import ./home.nix;
  };

  networking.firewall.allowedTCPPorts = [ 25565 64738 8181 ]; # terraria, minecraft, mumble-server, musicboty
  networking.firewall.allowedUDPPorts = [ 64738 8181 ]; # terraria, mumble-server, musicbot 

  system.stateVersion = "23.11";
}
