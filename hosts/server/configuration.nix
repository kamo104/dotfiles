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
      inputs.attic.nixosModules.atticd

      "${args.modules}/locale.nix"
      "${args.modules}/bluetooth.nix"
      "${args.modules}/pipewire.nix"
      "${args.modules}/common.nix"
      "${args.modules}/TShock-service.nix"
      "${args.modules}/duckdns.nix"
    ];
  # nixpkgs.overlays = [ 
  #   # inputs.nix-minecraft.overlay 
  #   inputs.attic.overlays.default
  # ];
  nix = {
    settings = {
      connect-timeout = 5;
      substituters = [
        "http://laptop.attic.internal:8080/hello"
      ];
      trusted-public-keys = [
        "hello:mDHjt00ORxJ/VMiZv6A3or65MpDaxAmyBqlSPfVoZqo="
      ];
      netrc-file = [
        "${args.secrets}/nix/netrc"
      ];
    };
  };
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
  };
  services.nfs.server = {
    enable = true;
    exports = ''
      /share/all  10.100.0.0/23(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash,fsid=1)
      /share/kamo 10.100.1.0/24(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash,fsid=2)
    '';
  };
  services.dnsmasq = {
    enable = true;
    settings = {
      # server = [ "8.8.8.8" "8.8.4.4" ];
      server = [ "10.64.0.1" ];
      # TODO: check openvpn interoparability
      address = [
        # home-assistant
        "/home-assistant.kkf.internal/10.100.0.1"
        # tshock I guess
        "/tshock.kkf.internal/10.100.0.1"
        # attic
        "/attic.kkf.internal/10.100.0.1"
        "/laptop.attic.internal/192.168.1.28"
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
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."home-assistant.kkf.internal" =  {
      # forceSSL = true;
      # sslCertificate =;
      locations."/" = {
        proxyPass = "http://192.168.1.98:8123";
        proxyWebsockets = true;
      };
    };
    virtualHosts."attic.kkf.internal" =  {
      # forceSSL = true;
      # sslCertificate =;
      locations."/" = {
        proxyPass = "http://localhost:8080";
      };
    };
    virtualHosts."jellyfin.kkf.internal" =  {
      # forceSSL = true;
      # sslCertificate =;
      locations."/" = {
        proxyPass = "http://localhost:8096";
        proxyWebsockets = true;
      };
    };
  };

  # services.atticd = {
  #   enable = true;
  #   credentialsFile = "${args.secrets}/attic/atticd.env";
  #   settings = {
  #     listen = "[::]:8080";
  #     allowed-hosts = [];
  #     garbage-collection = {
  #       interval = "0";
  #     };
  #     storage = {
  #       type = "local";
  #       path = "/drives/merged/attic/storage";
  #     };
  #     chunking = {
  #       nar-size-threshold = 64 * 1024; # 64 KiB
  #       min-size = 16 * 1024; # 16 KiB
  #       avg-size = 64 * 1024; # 64 KiB
  #       max-size = 256 * 1024; # 256 KiB
  #     };
  #   };
  # };

  # bluetooth.enable = true;
  locale.enable = true;
  # pipewire.enable = true;
  common.enable = true;
  common.users = ["kamo"];
  users.users.kamo.linger = true;

  # services.TShock.enable = true;
  # services.TShock.startCommand = ''
  #   ${TShock}/bin/TShock.Server -world /home/kamo/.local/share/Terraria/Worlds/Niebiański_Rubież_Harpii.wld
  # '';
  services.duckdns = {
    enable = true;
    domain = "grzymoserver";
    tokenFile = "/home/kamo/duckdns/token";
  };
  services.jellyfin = {
    enable = true;
  };
  users.groups = {nfs={gid=992;members=["kamo" "jellyfin"];};};
  users.users = {
    jellyfin = {
      isSystemUser = true;
      group = "jellyfin";
      description = "jellyfin";
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

  networking.nat = {
    enable = true;
    externalInterface = "ens18";
    internalInterfaces = [ "wg0" ];
  };
  # boot.kernel.sysctl = {
  #   "net.ipv4.conf.all.forwarding" = true;
  #   "net.ipv6.conf.all.forwarding" = true;
  # };
  networking.wg-quick.interfaces = {
    wg1 = {
      address = [ "10.67.130.19/32" ];
      privateKeyFile = "${args.secrets}/wg-keys/mullvad/private";
      dns = [ "10.64.0.1" ];
      peers = [
        {
          publicKey = "Qn1QaXYTJJSmJSMw18CGdnFiVM0/Gj/15OdkxbXCSG0=";
          endpoint = "se-mma-wg-001.relays.mullvad.net:51820";
          allowedIPs = [ "10.64.0.1/32" ];
        }
      ];
    };
    wg0 = {
      address = [ "10.100.0.1/23" ];
      listenPort = 42069;
      privateKeyFile = "${args.secrets}/wg-keys/internal/private";
      peers = [
        { # laptop
          publicKey = "ryK75fBpqS2coBrAmBRFrJAGxsXLhNsU9DOhk8mWzGc=";
          allowedIPs = [ "10.100.0.2/32" "10.100.1.2/32" ];
        } 
        { # phone
          publicKey = "7AEcF85PHwIStLUlOxDIz5b2DztG2M+FDjWEiSN8zT8=";
          allowedIPs = [ "10.100.0.3/32" "10.100.1.3/32" ];
        }
        { # desktop
          publicKey = "g8NdMICj52ocHRb65IqUMnN339gGzwS+BUwzB69LIGY=";
          allowedIPs = [ "10.100.0.4/32" "10.100.1.4/32" ];
        }
        # { # work-laptop
        #   publicKey = "xajjnlHmodUCFX6bkzqoBXuVsKKouE5TlAE/FlVHRmc=";
        #   allowedIPs = [ "10.100.0.6/32" ];
        # }
        { # kacper-desktop
          publicKey = "aUoBe14XYsRkUwIgBmQPoFG9+j/xzNLMLE/GeQ3v3F8=";
          allowedIPs = [ "10.100.0.69/32" ];
        }
      ];
    };
  };

  services.murmur = {
    enable = true;
    openFirewall = true;
    bandwidth = 256000;
  };

  environment.systemPackages = with pkgs; [
    mergerfs
  ];
  home-manager = {
    extraSpecialArgs = {inherit inputs; hmModules = args.hmModules; hostname = args.hostname;};
    useGlobalPkgs = true;
    useUserPackages  = true;
    users.kamo = import ./home.nix;
  };

  # networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 53 80 111 443 2049 ]; # dns, http, nfs rpc, https, nfs
  networking.firewall.allowedUDPPorts = [ 53 111 2049 42069 ]; # dns, nfs rpc, nfs rpc, nfs, wireguard

  system.stateVersion = "23.11";
}
