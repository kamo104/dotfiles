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
        # sha256="0p9ppzh8v6r9bcgsvcd0qp8akgip082km7rhwhibil14rnbsp931";
        # sha256="207a1cc1a455ae728a24fd5cb877db1e6329830ae0d403b462b3dfc29f726e88";
        sha256="sha256-k+TB2zASUSHkBlPulvv1wviEsnWGEScd1BvThFyLMzk=";
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
  services.duckdns = {
    enable = true;
    domain = "grzymoserver";
    tokenFile = "/home/kamo/duckdns/token";
  };
  

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

  # networking.nat.enable = true;
  # networking.nat.externalInterface = "ens18";
  # networking.nat.internalInterfaces = [ "wg0" ];
  boot.kernel.sysctl = {
    # if you use ipv4, this is all you need
    "net.ipv4.conf.all.forwarding" = true;

    # If you want to use it for ipv6
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.1/24" "10.101.0.1/24" ];
      listenPort = 42069;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      # postSetup = ''
      #   ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      # '';

      # # This undoes the above command
      # postShutdown = ''
      #   ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      # '';

      privateKeyFile = "/home/kamo/wg-keys/private";
      peers = [
        { # laptop
          publicKey = "ryK75fBpqS2coBrAmBRFrJAGxsXLhNsU9DOhk8mWzGc=";
          allowedIPs = [ "10.100.0.2/32" "10.101.0.2/32"];
        } 
        { # phone
          publicKey = "7AEcF85PHwIStLUlOxDIz5b2DztG2M+FDjWEiSN8zT8=";
          allowedIPs = [ "10.100.0.3/32" ];
        }
        { # desktop
          publicKey = "g8NdMICj52ocHRb65IqUMnN339gGzwS+BUwzB69LIGY=";
          allowedIPs = [ "10.100.0.4/32" ];
        }
        { # kacper-desktop
          publicKey = "aUoBe14XYsRkUwIgBmQPoFG9+j/xzNLMLE/GeQ3v3F8=";
          allowedIPs = [ "10.100.0.69/32" ];
        }
        { # home-assistant
          publicKey = "";
          allowedIPs = [ "10.101.0.5/32" ];
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
    botamusique
  ];
  home-manager = {
    extraSpecialArgs = {inherit inputs; hmModules = args.hmModules;};
    useGlobalPkgs = true;
    useUserPackages  = true;
    users.kamo = import ./home.nix;
  };

  networking.firewall.allowedTCPPorts = [ 8181 ]; # musicbot
  networking.firewall.allowedUDPPorts = [ 8181 42069 ]; # musicbot, wireguard

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


  system.stateVersion = "23.11";
}
