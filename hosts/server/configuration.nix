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
        sha256="sha256-nMz6JPr5IeFyZHnrTh6C8n/NXPO8fuC7wNXkZx6c8eo=";
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
      # inputs.nix-minecraft.nixosModules.minecraft-servers

      "${args.modules}/locale.nix"
      "${args.modules}/bluetooth.nix"
      "${args.modules}/pipewire.nix"
      "${args.modules}/common.nix"
      "${args.modules}/TShock-service.nix"
      "${args.modules}/duckdns.nix"
    ];
  # nixpkgs.overlays = [ 
  #   # inputs.nix-minecraft.overlay 
  # ];

  # REMOTE BUILDS
  # nix.buildMachines = [{
  #   hostName = "192.168.1.28";
  #   system = "x86_64-linux";
  #   protocol = "ssh-ng";
  #   # default is 1 but may keep the builder idle in between builds
  #   maxJobs = 0;
  #   speedFactor = 2;
  #   supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
  #   mandatoryFeatures = [ ];
  # }];
  # nix.distributedBuilds = true;
  # nix.settings = {
  #   builders-use-substitutes = true;
  # };

  fileSystems = {
    "/drives/hdd1" = { 
      device = "/dev/disk/by-uuid/acc830ed-f8bd-4bfe-98d6-3052bc4b1b16";
      fsType = "ext4";
      options = ["nofail"];
    };
    "/drives/merged" = { 
      device = "/drives/hdd*";
      fsType = "fuse.mergerfs";
      options = ["nofail" "category.create=lfs" "minfreespace=20G"]; # lfs makes the drives fill up in order
    };

    "/share/all" = {
      device = "/drives/merged/share/all";
      options = ["nofail" "bind"];
    };
    "/share/kamo" = {
      device = "/drives/merged/share/kamo";
      options = ["nofail" "bind"];
    };
    "/share/ola" = {
      device = "/drives/merged/share/ola";
      options = ["nofail" "bind"];
    };
    "/var/lib/immich" = {
      device = "/drives/merged/internal/immich";
      options = ["nofail" "bind"];
    };
  };
  services.nfs.server = {
    enable = true;
    exports = ''
      /share/all  10.100.0.0/16(async,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,fsid=1)
      /share/kamo 10.100.1.0/24(async,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,fsid=2)
      /share/ola  10.100.1.0/24(async,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,fsid=3)
    '';
  };
  services.dnsmasq = {
    enable = true;
    settings = {
      # TODO: do we really need to use 10.64.0.1 always?
      server = [ "10.64.0.1" "/duckdns.org/8.8.8.8" ];
      # TODO: check openvpn interoparability
      address = [
        # home-assistant
        "/home-assistant.kkf.internal/10.100.0.1"
        # tshock I guess
        "/tshock.kkf.internal/10.100.0.1"
        # jellyfin
        "/jellyfin.kkf.internal/10.100.0.1"
        # immich
        "/immich.kkf.internal/10.100.0.1"
        # mumble stuff
        "/mumble.kkf.internal/10.100.0.1"
        # nfs
        "/nfs.kkf.internal/10.100.0.1"
        # smb
        "/smb.kkf.internal/10.100.0.1"
      ];
    };
  };
  services.nginx = {
    enable = true;
    # recommendedProxySettings = true;
    # recommendedTlsSettings = true;
    clientMaxBodySize="0";
    virtualHosts."home-assistant.kkf.internal" =  {
      forceSSL = true;
      sslCertificate ="${args.secrets}/pki/issued/kkf.crt";
      sslCertificateKey ="${args.secrets}/pki/private/kkf.key";
      sslTrustedCertificate ="${args.secrets}/pki/ca.crt";
      locations."/" = {
        proxyPass = "http://192.168.1.98:8123";
        proxyWebsockets = true;
      };
    };
    virtualHosts."jellyfin.kkf.internal" =  {
      forceSSL = true;
      sslCertificate ="${args.secrets}/pki/issued/kkf.crt";
      sslCertificateKey ="${args.secrets}/pki/private/kkf.key";
      sslTrustedCertificate ="${args.secrets}/pki/ca.crt";
      locations."/" = {
        proxyPass = "http://localhost:8096";
        proxyWebsockets = true;
      };
    };
    virtualHosts."immich.kkf.internal" =  {
      forceSSL = true;
      sslCertificate ="${args.secrets}/pki/issued/kkf.crt";
      sslCertificateKey ="${args.secrets}/pki/private/kkf.key";
      sslTrustedCertificate ="${args.secrets}/pki/ca.crt";
      locations."/" = {
        proxyPass = "http://localhost:3001";
        proxyWebsockets = true;
      	# recommendedProxySettings = false;
      };
    };
  };

  services.immich = {
    enable = true;
    mediaLocation = "/var/lib/immich";
    # environment = {
    #   IMMICH_MACHINE_LEARNING_ENABLED=false;
    # };
  };

  services.murmur = {
    enable = true;
    openFirewall = true;
    bandwidth = 256000;
    sslCa = "${args.secrets}/pki/ca.crt";
    sslCert = "${args.secrets}/pki/issued/kkf.crt";
    sslKey = "${args.secrets}/pki/private/kkf.key";
  };

  environment.systemPackages = with pkgs; [
    mergerfs
  ];

  # bluetooth.enable = true;
  locale.enable = true;
  # pipewire.enable = true;
  common.enable = true;
  common.users = ["kamo"];

  # services.TShock.enable = true;
  # services.TShock.startCommand = ''
  #   ${TShock}/bin/TShock.Server -world /home/kamo/.local/share/Terraria/Worlds/Niebiański_Rubież_Harpii.wld
  # '';
  services.duckdns = {
    enable = true;
    domain = "grzymoserver";
    tokenFile = "${args.secrets}/duckdns/token";
  };
  services.jellyfin = {
    enable = true;
  };
  users = {
    groups = {
      pki = {
        members = [ "nginx" "murmur" ];
      };
      services = {
        members = [ "murmur" "jellyfin" "nginx" "immich" ];
      };
    };
    users = {
      kamo.linger = true;
      jellyfin = {
        isSystemUser = true;
        group = "jellyfin";
        description = "jellyfin";
      };
      immich = {
        isSystemUser = true;
        group = "immich";
        description = "immich";
      };
      murmur = {
        isSystemUser = true;
        group = "murmur";
        # description = "murmur";
      };
      nginx = {
        isSystemUser = true;
        group = "nginx";
        description = "nginx";
      };
    };
  };

  services.qemuGuest.enable = true;
  networking.hostName = "${args.hostname}";

  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/sda";
    };
  };

  networking.iproute2 = {
    enable = true;
    rttablesExtraConfig = ''
      200 wg1_table
    '';
  };
  # networking.nat = {
  #   enable = true;
  #   # externalInterface = "ens18";
  #   # internalInterfaces = [ "wg0" ];
  # };
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
  #   "net.ipv6.conf.all.forwarding" = true;
  };
  networking.wg-quick.interfaces = {
    wg1 = {
      address = [ "10.67.130.19/32" ];
      listenPort = 42070;
      privateKeyFile = "${args.secrets}/wg-keys/mullvad/private";
      dns = [ "10.64.0.1" ];
      table = "off";
      postUp = ''
        ip route add default dev wg1 table wg1_table
        ip rule add from 10.100.0.0/16 lookup wg1_table
        ip route add 10.64.0.1 dev wg1
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/16 -o wg1 -j MASQUERADE
        ${pkgs.iptables}/bin/iptables -t mangle -I PREROUTING -i wg1 -d 10.67.130.19/32 -j ACCEPT
      '';
      postDown = ''
        ip route del default dev wg1 table wg1_table
        ip rule del from 10.100.0.0/16 lookup wg1_table
        ip route del 10.64.0.1 dev wg1
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/16 -o wg1 -j MASQUERADE
        ${pkgs.iptables}/bin/iptables -t mangle -D PREROUTING -i wg1 -d 10.67.130.19/32 -j ACCEPT
      '';
      peers = [
        {
          publicKey = "Qn1QaXYTJJSmJSMw18CGdnFiVM0/Gj/15OdkxbXCSG0=";
          endpoint = "se-mma-wg-001.relays.mullvad.net:51820";
          allowedIPs = [ "0.0.0.0/0" ];
        }
      ];
    };
    wg0 = {
      # 10.100.0-127.*   - wireguard
      # 10.100.128-255.* - ovpn
      # 10.100.0.*   - server addresses
      # 10.100.1.*   - kamo
      # 10.100.11.*  - ola
      # 10.100.12.*  - kacper
      # 10.100.13.*  - filip
      address = [ "10.100.0.1/20" ];
      listenPort = 42069;
      privateKeyFile = "${args.secrets}/wg-keys/internal/private";
      postUp = ''
        ip route add 10.100.0.0/20 dev wg0 table wg1_table
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
      '';
      postDown = ''
        ip route del 10.100.0.0/20 dev wg0 table wg1_table
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
      '';
      peers = [
        { # laptop
          publicKey = "ryK75fBpqS2coBrAmBRFrJAGxsXLhNsU9DOhk8mWzGc=";
          allowedIPs = [ "10.100.1.2/32" ];
        }
        { # phone
          publicKey = "7AEcF85PHwIStLUlOxDIz5b2DztG2M+FDjWEiSN8zT8=";
          allowedIPs = [ "10.100.1.3/32" ];
        }
        { # desktop
          publicKey = "g8NdMICj52ocHRb65IqUMnN339gGzwS+BUwzB69LIGY=";
          allowedIPs = [ "10.100.1.4/32" ];
        }
        { # work-laptop
          publicKey = "xajjnlHomdUCFX6bkzqoBXuVsKKouE5TlAE/FlVHRmc=";
          allowedIPs = [ "10.100.1.6/32" ];
        }
        

        { # ola-laptop
          publicKey = "iigx1rGG/qUxpInRcJOORjHRdhHNZ+VQamJ67yYT0SU=";
          allowedIPs = [ "10.100.11.1/32" ];
        }
        { # ola-iphone
          publicKey = "dB7xPYW6MDXkCspiBpfBrge1NwCro9Zeab79O4opFmQ=";
          allowedIPs = [ "10.100.11.2/32" ];
        }


        { # kacper-desktop
          publicKey = "aUoBe14XYsRkUwIgBmQPoFG9+j/xzNLMLE/GeQ3v3F8=";
          allowedIPs = [ "10.100.12.69/32" ];
        }
        # { # kacper-babcia-laptop
        #   publicKey = "kiDX7mwkXK6ClijNuj3ikuC4wXBKRY3C5QkbTUritj4=";
        #   allowedIPs = [ "10.100.12.70/32" ];
        # }

        { # filip-desktop
          publicKey = "XdU/e1hXOJ4Kg+tAzrFJ7ePbvM49n/qAXF2/cmC49Cg=";
          allowedIPs = [ "10.100.13.1/32" ];
        }
        { # filip-macbook
          publicKey = "33P2cNynGV2CPNfWvIbSJZnnpo8ZJvlSoysJj/N7V3A=";
          allowedIPs = [ "10.100.13.2/32" ];
        }
      ];
    };
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs; hmModules = args.hmModules; hostname = args.hostname;};
    useGlobalPkgs = true;
    useUserPackages  = true;
    users.kamo = import ./home.nix;
  };

  # networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 53 80 111 443 2049 ]; # dns, http, nfs rpc, https, nfs
  networking.firewall.allowedUDPPorts = [ 53 111 2049 42069 42070 ]; # dns, nfs rpc, nfs, wireguard

  system.stateVersion = "23.11";
}
