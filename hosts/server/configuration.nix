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
      inputs.nix-minecraft.nixosModules.minecraft-servers

      "${args.modules}/locale.nix"
      "${args.modules}/bluetooth.nix"
      "${args.modules}/pipewire.nix"
      "${args.modules}/common.nix"
      "${args.modules}/TShock-service.nix"
      "${args.modules}/duckdns.nix"
    ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];
  nix = {
    settings = {
      connect-timeout = 5;
      substituters = [
        # "lan.attic.internal/cache"
        "10.100.0.2:8080/home"
      ];
      trusted-public-keys = [
        "home:mDHjt00ORxJ/VMiZv6A3or65MpDaxAmyBqlSPfVoZqo="
      ];
      netrc-file = [
        "/home/kamo/.config/nix/netrc"
      ];
    };
  };
  fileSystems."/drives/hdd1" =
    { 
      device = "/dev/disk/by-uuid/acc830ed-f8bd-4bfe-98d6-3052bc4b1b16";
      fsType = "ext4";
      options = ["user=kamo" "nofail"];
    };
  services.dnsmasq = {
    enable = true;
    settings = {
      server = [ "8.8.8.8" "8.8.4.4" ];
      address = [
        # home-assistant
        "/home-assistant.kkf.internal/10.100.0.1"
        # tshock I guess
        "/tshock.kkf.internal/10.100.0.1"
        # attic cache
        "/wg.attic.kkf.internal/10.100.0.1"
        "/lan.attic.kkf.internal/192.168.1.82"
        # jellyfin
        "/jellyfin.kkf.internal/10.100.0.1"
        # immich
        "/immich.kkf.internal/10.100.0.1"
        # mumble stuff
        "/mumble.kkf.internal/10.100.0.1"
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
    virtualHosts."wg.attic.kkf.internal" =  {
      # forceSSL = true;
      # sslCertificate =;
      locations."/" = {
        proxyPass = "http://localhost:8080";
      };
    };
    virtualHosts."lan.attic.kkf.internal" =  {
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

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 42069;

      privateKeyFile = "/home/kamo/wg-keys/private";
      peers = [
        { # laptop
          publicKey = "ryK75fBpqS2coBrAmBRFrJAGxsXLhNsU9DOhk8mWzGc=";
          allowedIPs = [ "10.100.0.2/32" ];
        } 
        { # phone
          publicKey = "7AEcF85PHwIStLUlOxDIz5b2DztG2M+FDjWEiSN8zT8=";
          allowedIPs = [ "10.100.0.3/32" ];
        }
        { # desktop
          publicKey = "g8NdMICj52ocHRb65IqUMnN339gGzwS+BUwzB69LIGY=";
          allowedIPs = [ "10.100.0.4/32" ];
        }
        { # work-laptop
          publicKey = "xajjnlHmodUCFX6bkzqoBXuVsKKouE5TlAE/FlVHRmc=";
          allowedIPs = [ "10.100.0.6/32" ];
        }
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

  networking.firewall.allowedTCPPorts = [ 53 80 443 ]; # dns, http, https
  networking.firewall.allowedUDPPorts = [ 53 42069 ]; # dns, wireguard

  system.stateVersion = "23.11";
}
