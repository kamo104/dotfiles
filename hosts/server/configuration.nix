{ config, pkgs, inputs, ... } @args:
{
  imports =
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      "${args.modules}/locale.nix"
      "${args.modules}/bluetooth.nix"
      "${args.modules}/pipewire.nix"
      "${args.modules}/common.nix"
      # "${args.modules}/vban.nix"
    ];

  # bluetooth.enable = true;
  locale.enable = true;
  # pipewire.enable = true;
  common.enable = true;
  common.users = ["kamo"];
  # vban.enable = true;
  # vban.startScript = ''
  #   ${pkgs.pipewire}/bin/pw-cli load-module -m libpipewire-module-vban-recv stream.props={audio.rate=48000 audio.format=S16LE} sess.name="audio" source.ip="192.168.1.54" sess.latency.msec=30 &
  #   ${pkgs.pipewire}/bin/pw-cli load-module -m libpipewire-module-vban-send audio.format="S16LE" audio.rate=44100 sess.name="samson" destination.ip="192.168.1.54" sess.latency.msec=10
  # '';

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
    # terraria-server
    (pkgs.callPackage "${args.customPackages}/TShock/TShock.nix" {})
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
