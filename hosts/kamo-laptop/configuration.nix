{ config, pkgs, inputs, ... } @args:
{
  imports =
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      # inputs.hyprland.nixosModules.default
      # inputs.attic.nixosModules.atticd

      # "${args.modules}/hyprland.nix"
      # "${args.modules}/steam.nix"
      # "${args.modules}/virt.nix"
      # "${args.modules}/obs.nix"
      "${args.modules}/locale.nix"
      "${args.modules}/fonts.nix"
      # "${args.modules}/bluetooth.nix"
      # "${args.modules}/pipewire.nix"
      "${args.modules}/opencl.nix"
      "${args.modules}/opengl.nix"
      # "${args.modules}/wireshark.nix"
      "${args.modules}/common.nix"
      # "${args.modules}/vban.nix"
      # "${args.modules}/sunshine.nix"
    ];

  
  # MONERO:
  # systemd.services.monero = {
  #   requires = [ "wg-quick-wg1.service" ];
  # };
  services.monero = {
    enable = true;
    rpc = {
      address = "0.0.0.0";
      port = 18081;
      restricted = true;
    };
    limits = {
      upload = 209715;
      download = 209715;
    };
    extraConfig = ''
      proxy=127.0.0.1:9050
      tx-proxy=tor,127.0.0.1:9050
      confirm-external-bind=true

      p2p-bind-ip=0.0.0.0
      p2p-bind-port=18080
      igd=enabled
      # no-igd=1

      rpc-ssl=enabled
      rpc-ssl-private-key=/var/lib/monero/private.key
      rpc-ssl-certificate=/var/lib/monero/ca.cert
    '';
  };

  # TOR:
  services.tor = {
    enable = true;
    relay = {
      enable = true;
      role = "relay";
    };
    client = {
      enable = true;
      socksListenAddress = {
        IsolateDestAddr = true;
        addr = "127.0.0.1";
        port = 9050;
      };
    };
  };

  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  # DISABLE THE DISPLAY
  # boot.kernelParams = [
  #   "amdgpu.dc=1"
  #   "video=eDP-1:d"
  # ];

  # I2P:
  # services.i2pd = {
  #   enable = true;
  #   # upnp.enable = true;
  #   proto = {
  #     http = {
  #       enable = true;
  #       port = 7070;
  #       address = "127.0.0.1";
  #     };
  #     httpProxy = {
  #       enable = true;
  #       address = "10.100.1.2";
  #       port = 4447;
  #     };
  #   };
  # };

  # services.nginx = {
  #   enable = true;
  # };
  #
  #
  containers = {
    gitlab = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.10";
      localAddress = "192.168.100.11";
      config = { config, pkgs, lib, ... }: {
        system.stateVersion = "23.11";
        networking = {
          firewall = {
            enable = true;
            allowedTCPPorts = [ 80 ];
          };
          # Use systemd-resolved inside the container
          # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
          useHostResolvConf = lib.mkForce false;
        };
        services.nginx = {
          enable = true;
          recommendedProxySettings = true;
          virtualHosts = {
            localhost = {
              locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
            };
          };
        };
        services.gitlab = {
          enable = true;
          # openssl genrsa 512 | grep -v '\-----' | head -c 64
          # databasePasswordFile = "${args.secrets}/gitlab/dbPassword";
          # initialRootPasswordFile = pkgs.writeText "rootPassword" "dakqdvp4ovhksxer";
          # databaseName = "gitlab";
          # secrets = {
          #   secretFile = "${args.secrets}/gitlab/secret";
          #   otpFile = "${args.secrets}/gitlab/otp";
          #   # dbFile = "${args.secrets}/gitlab/db";
          #   dbFile = "/var/lib/gitlab/db";
          #   # jwsFile = pkgs.runCommand "oidcKeyBase" {} "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
          #   jwsFile = "${args.secrets}/gitlab/oidcKeyBase";
          # };
          databasePasswordFile = pkgs.writeText "dbPassword" "zgvcyfwsxzcwr85l";
          initialRootPasswordFile = pkgs.writeText "rootPassword" "dakqdvp4ovhksxer";
          secrets = {
            secretFile = pkgs.writeText "secret" "Aig5zaic";
            otpFile = pkgs.writeText "otpsecret" "Riew9mue";
            dbFile = pkgs.writeText "dbsecret" "we2quaeZ";
            jwsFile = pkgs.runCommand "oidcKeyBase" {} "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
          };
        };
      };
    };
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

  # bluetooth.enable = true;
  locale.enable = true;
  cfonts.enable = true;
  # pipewire.enable = true;
  opencl.enable = true;
  opengl.enable = true;
  # hyprland.enable = true;
  # services.displayManager = {
  #   autoLogin.enable = true;
  #   autoLogin.user = "kamo";
  # };
  # sunshine.enable = true;
  # steam.enable = true;
  # virt.enable = true;
  # virt.users = ["kamo"];
  # obs.enable = true;
  # wireshark.enable = true;
  # wireshark.users = ["kamo"];
  common.enable = true;
  common.users = ["kamo"];
  # vban.enable = true;
  # vban.startScript = ''
  #   ${pkgs.pipewire}/bin/pw-cli load-module -m libpipewire-module-vban-recv stream.props={audio.rate=48000 audio.format=S16LE} sess.name="audio" source.ip="10.100.1.4" sess.latency.msec=30 &
  #   ${pkgs.pipewire}/bin/pw-cli load-module -m libpipewire-module-vban-send audio.format="S16LE" audio.rate=44100 sess.name="samson" destination.ip="10.100.1.4" sess.latency.msec=10 &


  #   ${pkgs.pipewire}/bin/pw-cli load-module -m libpipewire-module-vban-recv stream.props={audio.rate=48000 audio.format=S16LE} sess.name="audio" source.ip="10.100.1.6" sess.latency.msec=30 &
  #   ${pkgs.pipewire}/bin/pw-cli load-module -m libpipewire-module-vban-send audio.format="S16LE" audio.rate=48000 sess.name="samson" destination.ip="10.100.1.6" sess.latency.msec=10
    
  # '';

  # systemd.user.services.loginlock = {
  #   description = "Lock session on startup";
  #   wants = [ "hypridle.service" ];
  #   after = [ "hypridle.service" ];
  #   wantedBy = [ "xdg-desktop-autostart.target" ];

  #   serviceConfig = {
  #     Type = "oneshot";
  #   };
  #   script = ''
  #     sleep 1; loginctl lock-session
  #   '';
  # };

  # services.avahi = {
  #   enable = true;
  #   nssmdns4 = true;
  #   ipv4 = true;
  #   ipv6 = true;
  #   publish = {
  #     enable = true;
  #     addresses = true;
  #     workstation = true;
  #     userServices = true;
  #   };
  # };

  fileSystems = {
    "/mnt/kkf" = {
      device = "nfs.kkf.internal:/share";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" "nofail" 
                  "x-systemd.requires=wg-quick-wg1.service"];
    };
  };

  networking.hostName = "kamo-laptop";
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      configurationLimit = 5;
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

 
  # services.printing.enable = true;

  # services.udev.packages = with pkgs; [ 
  #   stlink
  #   platformio-core.udev
  #   android-udev-rules
  # ];

  home-manager = {
    extraSpecialArgs = {inherit inputs; hmModules = args.hmModules; hostname = args.hostname; secrets = args.secrets;customPkgs = args.customPkgs;};
    useGlobalPkgs = true;
    useUserPackages  = true;
    users.kamo = import ./home.nix;
  };

  services.zerotierone = {
    enable = true;
    joinNetworks = ["1c33c1ced078606c"];
  };

  systemd.services.wireguard-ddns-check =
  let
    ddnsHost = "grzymoserver.duckdns.org";
    ipFile = "/var/lib/wireguard-ddns/ip.txt";
  in {
    description = "Check DDNS IP and restart WireGuard if changed";
    script = ''
      set -euo pipefail

      mkdir -p ${builtins.dirOf ipFile}

      resolved_ip=$(${pkgs.getent}/bin/getent ahosts ${ddnsHost} | tail -n 2 | head -n 1 | cut -d ' ' -f 1)

      if [ -z "$resolved_ip" ]; then
        echo "Failed to resolve IP for ${ddnsHost}" >&2
        exit 1
      fi

      if [ ! -f ${ipFile} ]; then
        echo "$resolved_ip" > ${ipFile}
        exit 0
      fi

      old_ip=$(cat ${ipFile})

      if [ "$resolved_ip" != "$old_ip" ]; then
        echo "IP changed: $old_ip → $resolved_ip"
        echo "$resolved_ip" > ${ipFile}
        ${pkgs.systemd}/bin/systemctl restart wg-quick-wg1.service
      else
        echo "IP didn't change: $old_ip"
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };
  systemd.timers.wireguard-ddns-check = {
    description = "Timer to check DDNS for WireGuard";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30sec";
      OnUnitActiveSec = "30sec";
      Persistent = true;
    };
  };
  
  networking.iproute2 = {
    enable = true;
    rttablesExtraConfig = ''
      200 vpn
    '';
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
  };
  networking.firewall = {
    allowedTCPPorts = [ 6881 18080 18081 ]; # deluge, monero P2P, monero RPC
    allowedUDPPorts = [ 1900 6881 42069 ]; # upnp, deluge, wireguard 
  
    extraCommands = ''
      ${pkgs.iproute2}/bin/ip rule add to 10.100.0.0/16 lookup vpn
    '';
    extraStopCommands = ''
      ${pkgs.iproute2}/bin/ip rule del to 10.100.0.0/16 lookup vpn
    '';
  };

  services.resolved.enable = true;
  networking.wg-quick.interfaces = {
    wg1 = {
      address = [ "10.100.1.2/32" ];
      listenPort = 42069;
      privateKeyFile = "${args.secrets}/wg-keys/internal/private";
      dns = ["10.100.0.1" "~kkf.internal"];
      table = "off";
      postUp = ''
        # scoped DNS
        ${pkgs.systemd}/bin/resolvectl domain wg1 '~kkf.internal'

        ${pkgs.iproute2}/bin/ip route add default dev wg1 table vpn
        # ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/16 -o wg1 -j MASQUERADE
        # ${pkgs.iptables}/bin/iptables -t mangle -I PREROUTING -i wg1 -d 10.100.1.2/32 -j ACCEPT
      '';
      postDown = ''
        ${pkgs.iproute2}/bin/ip route del default dev wg1 table vpn
        # ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/16 -o wg1 -j MASQUERADE
        # ${pkgs.iptables}/bin/iptables -t mangle -D PREROUTING -i wg1 -d 10.100.1.2/32 -j ACCEPT
      '';
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
