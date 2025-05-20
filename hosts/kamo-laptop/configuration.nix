{ config, pkgs, inputs, ... } @args:
{
  imports =
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      # inputs.hyprland.nixosModules.default
      # inputs.attic.nixosModules.atticd

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
  # MONERO:
  services.monero = {
    enable = true;
    dataDir = "/home/kamo/Documents/chain";
    rpc = {
      address = "0.0.0.0";
      # address = "10.100.1.2";
      port = 18081;
      restricted = true;
    };
    extraConfig = ''
      proxy=127.0.0.1:9050
      tx-proxy=tor,127.0.0.1:9050
      confirm-external-bind=1
      p2p-bind-ip=127.0.0.1
      p2p-bind-port=18080
      no-igd=1
    '';
  };

  # TOR:
  services.tor = {
    enable = true;
    client.socksListenAddress = {
      IsolateDestAddr = true;
      addr = "127.0.0.1";
      port = 9050;
    };
    # settings = {
    #   SocksPort = [
    #     {
    #       port = 9050;
    #     }
    #   ];
    # };
  };



  # guitarix pipewire.jack
  # security.pam.loginLimits = [
  #   {
  #     domain = "*";
  #     type = "-";
  #     item = "memlock";
  #     value = "8192000";
  #   }
  #   {
  #     domain = "*";
  #     type = "-";
  #     item = "rtprio";
  #     value = "95";
  #   }
  # ];
  bluetooth.enable = true;
  locale.enable = true;
  cfonts.enable = true;
  pipewire.enable = true;
  # opencl.enable = true;
  opengl.enable = true;
  hyprland.enable = true;
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "kamo";
  };
  # sunshine.enable = true;
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
    ${pkgs.pipewire}/bin/pw-cli load-module -m libpipewire-module-vban-recv stream.props={audio.rate=48000 audio.format=S16LE} sess.name="audio" source.ip="10.100.1.4" sess.latency.msec=30 &
    ${pkgs.pipewire}/bin/pw-cli load-module -m libpipewire-module-vban-send audio.format="S16LE" audio.rate=44100 sess.name="samson" destination.ip="10.100.1.4" sess.latency.msec=10 &


    ${pkgs.pipewire}/bin/pw-cli load-module -m libpipewire-module-vban-recv stream.props={audio.rate=48000 audio.format=S16LE} sess.name="audio" source.ip="10.100.1.6" sess.latency.msec=30 &
    ${pkgs.pipewire}/bin/pw-cli load-module -m libpipewire-module-vban-send audio.format="S16LE" audio.rate=48000 sess.name="samson" destination.ip="10.100.1.6" sess.latency.msec=10
    
  '';

  systemd.user.services.loginlock = {
    description = "Lock session on startup";
    wants = [ "hypridle.service" ];
    after = [ "hypridle.service" ];
    wantedBy = [ "xdg-desktop-autostart.target" ];

    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      sleep 1; loginctl lock-session
    '';
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };

  fileSystems = {
    "/mnt/kkf" = {
      device = "nfs.kkf.internal:/share";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" "nofail" 
                  "x-systemd.requires=wg-quick-wg0.service"];
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
  # force deep sleep for lower battery drain
  # boot.kernelParams = [ "mem_sleep_default=deep" ];
  services.tlp = {
    enable = true;
    settings = {
      # performance on AC
      CPU_ENERGY_PERF_POLICY_ON_AC="performance";
      PLATFORM_PROFILE_ON_AC="performance";
      # longevity on battery
      CPU_ENERGY_PERF_POLICY_ON_BAT="power";
      PLATFORM_PROFILE_ON_BAT="low-power";
      CPU_BOOST_ON_BAT=0;
      CPU_HWP_DYN_BOOST_ON_BAT=0;
      AMDGPU_ABM_LEVEL_ON_BAT=3;
      MEM_SLEEP_ON_AC="s2idle";
      MEM_SLEEP_ON_BAT="deep";
    };
  };


  # machenike
  # boot.initrd.kernelModules = ["xpad"];
  # system.activationScripts = {
  #   MachenikeFix.text = ''
  #     echo -n "2345:e00b:ik" | tee /sys/module/usbcore/parameters/quirks
  #   '';
  # };
  # services.udev.extraRules = ''
  #   ACTION=="add", ATTRS{idVendor}=="2345", ATTRS{idProduct}=="e00b", RUN+="/sbin/modprobe xpad" RUN+="/bin/sh -c 'echo 2345 e00b > /sys/bus/usb/drivers/xpad/new_id'"
  #   '';

 
  services.printing.enable = true;

  services.udev.packages = with pkgs; [ 
    stlink
    platformio-core.udev
    android-udev-rules
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs; hmModules = args.hmModules; hostname = args.hostname; secrets = args.secrets;customPkgs = args.customPkgs;};
    useGlobalPkgs = true;
    useUserPackages  = true;
    users.kamo = import ./home.nix;
  };

  networking.firewall.allowedTCPPorts = [ 6881 18081 ]; # deluge
  networking.firewall.allowedUDPPorts = [ 1900 6881 42069 ]; # upnp, deluge, wireguard 

  services.zerotierone = {
    enable = true;
    joinNetworks = ["1c33c1ced078606c"];
  };

  services.resolved.enable = true;
  networking.wg-quick.interfaces = {
    wg0 = {
      autostart = false;
      address = [ "10.100.1.2/32" ];
      listenPort = 42069;
      privateKeyFile = "${args.secrets}/wg-keys/internal/private";
      dns = ["10.100.0.1" "~kkf.internal"];
      postUp = ''
        ${pkgs.systemd}/bin/resolvectl domain wg0 '~kkf.internal'
      '';
      peers = [
        {
          publicKey = "oT6pJKSYRfosjzNQ9nUNQiDDyDzZylVCCJ8ePNXwX0Y=";
          allowedIPs = [ "10.100.0.0/16" ];
          endpoint = "grzymoserver.duckdns.org:42069";
          persistentKeepalive = 25;
        }
      ];
    };
    wg1 = {
      autostart = false;
      address = [ "10.100.1.2/32" ];
      listenPort = 42069;
      privateKeyFile = "${args.secrets}/wg-keys/internal/private";
      dns = ["10.100.0.1"];
      # windows:
      # PS C:\Windows\system32> Add-DnsClientNrptRule -Namespace ".kkf.internal" -NameServers 10.100.0.1 -DisplayName kkfRule
      # PS C:\Windows\system32> Remove-DnsClientNrptRule -Force -Name "$(Get-DnsClientNrptRule | Where-Object { $_.DisplayName -like "*kkfRule*" } | Select-Object -ExpandProperty Name)"

      peers = [
        {
          publicKey = "oT6pJKSYRfosjzNQ9nUNQiDDyDzZylVCCJ8ePNXwX0Y=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "grzymoserver.duckdns.org:42069";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  system.stateVersion = "23.11";
}
