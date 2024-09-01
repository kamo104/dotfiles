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
      "${args.modules}/opencl.nix"
      "${args.modules}/opengl.nix"
      "${args.modules}/wireshark.nix"
      "${args.modules}/common.nix"
      "${args.modules}/vban.nix"
      "${args.modules}/sunshine.nix"
    ];

  bluetooth.enable = true;
  locale.enable = true;
  cfonts.enable = true;
  pipewire.enable = true;
  opencl.enable = true;
  opengl.enable = true;
  hyprland.enable = true;
  # sunshine.enable = true;
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

  fileSystems = {
    "/mnt/kkf" = {
      device = "nfs.kkf.internal:/share";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" "nofail" ];
    };
  };


  networking.hostName = "kamo-laptop";
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      configurationLimit = 10;
    };
    efi = {
      canTouchEfiVariables = true;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # machenike
  boot.initrd.kernelModules = ["xpad"];
  system.activationScripts = {
    MachenikeFix.text = ''
      echo -n "2345:e00b:ik" | tee /sys/module/usbcore/parameters/quirks
    '';
  };
  services.udev.extraRules = ''
    ACTION=="add", ATTRS{idVendor}=="2345", ATTRS{idProduct}=="e00b", RUN+="/sbin/modprobe xpad" RUN+="/bin/sh -c 'echo 2345 e00b > /sys/bus/usb/drivers/xpad/new_id'"
    '';

 
  services.printing.enable = true;

  services.udev.packages = with pkgs; [ 
    stlink
    platformio-core.udev
    android-udev-rules
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs; hmModules = args.hmModules; hostname = args.hostname;};
    useGlobalPkgs = true;
    useUserPackages  = true;
    users.kamo = import ./home.nix;
  };

  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ 42069 ]; # wireguard 

  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.100.1.2/23"]; # "10.100.1.2/23" 
      listenPort = 42069;
      privateKeyFile = "/home/kamo/wg-keys/private";
      dns = ["10.100.0.1"];
      peers = [
        {
          publicKey = "oT6pJKSYRfosjzNQ9nUNQiDDyDzZylVCCJ8ePNXwX0Y=";
          allowedIPs = [ "10.100.0.0/23" ];
          endpoint = "grzymoserver.duckdns.org:42069";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  system.stateVersion = "23.11";
}
