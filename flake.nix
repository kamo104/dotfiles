{
  description = "Nixos config flake";

  inputs = {
    # hyprland = {
    #   url = "github:hyprwm/Hyprland";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    signalPkgs.url = "github:nixos/nixpkgs?rev=b1000dc9e4790cbbd69b9140b23e28afad3bf34f";
    # bambuPkgs.url = "github:nixos/nixpkgs?rev=18fcf074a288cebc14a8334ea62da0c25b39574b";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags?rev=60180a184cfb32b61a1d871c058b31a3b9b0743d";
      # url = "tarball+https://codeload.github.com/Aylur/ags/tar.gz/60180a184cfb32b61a1d871c058b31a3b9b0743d";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... } @inputs:
  with builtins; let 
    modules = "${self}/nixosModules";
    hmModules = "${self}/homeManagerModules";
    customPkgs = "${self}/nixosPackages";
    secrets = "/etc/secrets";

    hostNames = attrNames (readDir "${self}/hosts");
    hostConfiguration = host: nixpkgs.lib.nixosSystem {
      specialArgs = {
          inherit inputs modules hmModules customPkgs secrets;
          hostname = "${host}";
      };
      modules = [
        "${self}/hosts/${host}/configuration.nix"
      ];
    };
    mapper = map (host: {"name" = "${host}"; "value" = hostConfiguration host;});
    createHosts = hosts: listToAttrs (mapper hosts);
  in
  {
    nixosConfigurations = createHosts hostNames;
    
    # base nix profile system packages for non nixos systems
    packages."x86_64-linux"."work-laptop" = 
    let 
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in
      pkgs.buildEnv{
        name = "work-laptop";
        paths = import "${modules}/common-pkgs.nix" {inherit pkgs customPkgs;};
      };


    # kamo-mac default packages profile
    # packages."aarch64-darwin"."kamo-mac" = 
    # let 
    #   pkgs = nixpkgs.legacyPackages."aarch64-darwin";
    # in
    #   pkgs.buildEnv{
    #     name = "work-laptop";
    #     paths = import "${modules}/common-pkgs.nix" {inherit pkgs customPkgs;};
    #   };
    # home manager configuration for non nixos systems
    homeConfigurations = {
    # work-laptop hm config
      work-laptop = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = {
          inherit inputs modules hmModules customPkgs;
          hostname = "work-laptop";
        };
        modules = [
          ./hosts/work-laptop/home.nix
        ];
      };
    };
    # mac hm config
    kamo-mac = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages."aarch64-darwin";
      extraSpecialArgs = {
        inherit inputs modules hmModules customPkgs;
        hostname = "kamo-mac";
      };
      modules = [
        ./hosts/kamo-mac/home.nix
      ];
    };
  };
}
