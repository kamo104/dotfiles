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

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    # other Nginx options
    virtualHosts."test.internal" =  {
    # serverName = "test.internal";
      # enableACME = true;
      # forceSSL = true;
      locations."/" = {
        proxyPass = "http://192.168.1.98:8123";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;" +
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;"
          ;
      };
    };
  };
  networking.extraHosts = ''127.0.0.1 test.internal'';


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

  # environment.systemPackages = with pkgs; 
  # let 
  # customKodi = pkgs.kodi-wayland.withPackages (p: with p; [
  #     joystick
  #     # jellyfin
  #     # kodi-retroarch-advanced-launchers
  #     # kodiPackages.steam-launcher
  # ]);
  # in
  # [
  #   customKodi
  # ];



  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = let
  #     linux_pkg = { fetchgit, buildLinux, ... } @ args:

  #       buildLinux (args // rec {
  #         version = "6.10.0-rc5";
  #         modDirVersion = version;

  #         src = fetchgit
  #           {
  #             url = "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/";
  #             rev = "f2661062f16b2de5d7b6a5c42a9a5c96326b8454";
  #             sha256 = "sha256-jdVowvRzVO2IBWad7yVHuGZhmq6F3OM51PJVMuNjWK4=";
  #           };

  #         kernelPatches = [ ];

  #         extraMeta.branch = "6.10.0-rc5";
  #       } // (args.argsOverride or { }));
  #     linux_6-10-5rc = pkgs.callPackage linux_pkg { };
  #   in
  #   pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_6-10-5rc);
  
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

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "1c33c1ced078606c" "af78bf943600feb0"];
    localConf.settings = { 
      softwareUpdate = "disable";
    };
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

  networking.firewall.allowedTCPPorts = [ 25565 ]; # minecraft
  networking.firewall.allowedUDPPorts = [ 25565 42069 ]; # minecraft, wireguard 
  # networking.firewall = {
  #   allowedUDPPorts = [ 5353 ]; # For device discovery
  #   allowedUDPPortRanges = [{ from = 32768; to = 61000; }];   # For Streaming
  #   allowedTCPPorts = [ 8010 25565 ];  # For gnomecast server minecraft
  # };

  # services.avahi = {
  #   enable = true;
  #   openFirewall = true;
  #   nssmdns4 = true;
  #   nssmdns6 = true;
  #   publish = {
  #     enable = true;
  #     addresses = true;
  #     domain = true;
  #     hinfo = true;
  #     userServices = true;
  #     workstation = true;
  #   };
  # };

  # services.minecraft-servers ={
  #   openFirewall = true;
  #   enable = true;
  #   eula = true;
  #   user = "kamo";
  #   group = "users";
  #   servers = {
  #     rpg = {
  #       enable = true;
  #       autoStart = true;
  #       package = pkgs.fabricServers.fabric-1_20_1;
  #       serverProperties = {
  #         online-mode = false;
  #       };
  #       symlinks = {
  #         mods = with pkgs; pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
  #           Starlight = fetchurl { url = "https://cdn.modrinth.com/data/H8CaAYZC/versions/XGIsoVGT/starlight-1.1.2%2Bfabric.dbc156f.jar"; sha512 = "6b0e363fc2d6cd2f73b466ab9ba4f16582bb079b8449b7f3ed6e11aa365734af66a9735a7203cf90f8bc9b24e7ce6409eb04d20f84e04c7c6b8e34f4cc8578bb"; };
  #           Lithium = fetchurl { url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/ZSNsJrPI/lithium-fabric-mc1.20.1-0.11.2.jar"; sha512 = "d1b5c90ba8b4879814df7fbf6e67412febbb2870e8131858c211130e9b5546e86b213b768b912fc7a2efa37831ad91caf28d6d71ba972274618ffd59937e5d0d"; };
  #           FerriteCore = fetchurl { url = "https://cdn.modrinth.com/data/uXXizFIs/versions/ULSumfl4/ferritecore-6.0.0-forge.jar"; sha512 = "e78ddd02cca0a4553eb135dbb3ec6cbc59200dd23febf3491d112c47a0b7e9fe2b97f97a3d43bb44d69f1a10aad01143dcd84dc575dfa5a9eaa315a3ec182b37"; };
  #           Krypton = fetchurl { url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/jiDwS0W1/krypton-0.2.3.jar"; sha512 = "92b73a70737cfc1daebca211bd1525de7684b554be392714ee29cbd558f2a27a8bdda22accbe9176d6e531d74f9bf77798c28c3e8559c970f607422b6038bc9e"; };
  #           LazyDFU = fetchurl { url = "https://cdn.modrinth.com/data/hvFnDODi/versions/0.1.3/lazydfu-0.1.3.jar"; sha512 = "dc3766352c645f6da92b13000dffa80584ee58093c925c2154eb3c125a2b2f9a3af298202e2658b039c6ee41e81ca9a2e9d4b942561f7085239dd4421e0cce0a"; };
  #           C2ME = fetchurl { url = "https://cdn.modrinth.com/data/VSNURh3q/versions/t4juSkze/c2me-fabric-mc1.20.1-0.2.0%2Balpha.10.91.jar"; sha512 = "562c87a50f380c6cd7312f90b957f369625b3cf5f948e7bee286cd8075694a7206af4d0c8447879daa7a3bfe217c5092a7847247f0098cb1f5417e41c678f0c1"; };
  #         });
  #       };
  #     };
  #   };
  # };


  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.2/24" ];
      listenPort = 42069;
      privateKeyFile = "/home/kamo/wg-keys/private";
      peers = [
        {
          publicKey = "oT6pJKSYRfosjzNQ9nUNQiDDyDzZylVCCJ8ePNXwX0Y=";
          allowedIPs = [ "10.100.0.0/24" ];
          endpoint = "grzymoserver.duckdns.org:42069";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  

  system.stateVersion = "23.11";
}
