{ config, pkgs, inputs, ... } @args:
{
  imports =
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      inputs.hyprland.nixosModules.default
      "${args.modules}/hyprland.nix"
      
      "${args.modules}/steam.nix"
      "${args.modules}/virt.nix"
      "${args.modules}/obs.nix"
      "${args.modules}/locale.nix"
      "${args.modules}/fonts.nix"
      "${args.modules}/bluetooth.nix"
      "${args.modules}/pipewire.nix"
      "${args.modules}/grub.nix"
      "${args.modules}/opencl.nix"
      "${args.modules}/opengl.nix"
      "${args.modules}/wireshark.nix"
      "${args.modules}/common.nix"
      "${args.modules}/vban.nix"
    ];

  bluetooth.enable = true;
  locale.enable = true;
  cfonts.enable = true;
  pipewire.enable = true;
  grub.enable = true;
  opencl.enable = true;
  opengl.enable = true;
  hyprland.enable = true;
  # services.xserver = {
  #   enable = true;
  #   displayManager.gdm.enable = true;
  #   desktopManager.gnome.enable = true;
  # };
  steam.enable = true;
  virt.enable = true;
  virt.users = ["kamo"];
  obs.enable = true;
  wireshark.enable = true;
  wireshark.users = ["kamo"];
  common.enable = true;
  common.users = ["kamo"];
  vban.enable = true;
  vban.startScript = ''
    ${pkgs.pipewire}/bin/pw-cli load-module -m libpipewire-module-vban-recv stream.props={audio.rate=48000 audio.format=S16LE} sess.name="audio" source.ip="192.168.1.54" sess.latency.msec=30 &
    ${pkgs.pipewire}/bin/pw-cli load-module -m libpipewire-module-vban-send audio.format="S16LE" audio.rate=44100 sess.name="samson" destination.ip="192.168.1.54" sess.latency.msec=10
  '';

  networking.hostName = "kamo-laptop";

  services.printing.enable = true;

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "1c33c1ced078606c" "af78bf943600feb0"];
  };
  services.udev.packages = with pkgs; [ 
    stlink
    platformio-core.udev
    android-udev-rules
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs; hmModules = args.hmModules;};
    useGlobalPkgs = true;
    useUserPackages  = true;
    users.kamo = import ./home.nix;
  };

  networking.firewall.allowedTCPPorts = [ 7777 25565 64738 8181 ]; # terraria, minecraft, mumble-server, musicboty
  networking.firewall.allowedUDPPorts = [ 7777 64738 8181 ]; # terraria, 

  system.stateVersion = "23.11";
}
