{
  description = "Nixos config flake";

  inputs =
  {
    # hyprland = {
    #   url = "github:hyprwm/Hyprland";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nix-darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:hraban/mac-app-util";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
    hostConfiguration = createFn: host: createFn {
      specialArgs = {
          inherit inputs modules hmModules customPkgs secrets;
          hostname = "${host}";
      };
      modules = [
        "${self}/hosts/${host}/configuration.nix"
      ];
    };
    mapper = createFn: hosts: map (host: {"name" = "${host}"; "value" = hostConfiguration createFn host;}) hosts;
    createHosts = createFn: listToAttrs (mapper createFn hostNames);
  in
  {
    # nixos configurations
    nixosConfigurations = createHosts nixpkgs.lib.nixosSystem;
    # macos configurations
    darwinConfigurations = createHosts inputs.nix-darwin.lib.darwinSystem;
    
    # base nix profile system packages for non nixos systems
    packages."x86_64-linux"."work-laptop" = 
    let 
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in
      pkgs.buildEnv{
        name = "work-laptop";
        paths = import "${modules}/common-pkgs.nix" {inherit pkgs customPkgs;};
      };
    # home-manager configuration for standalone installs
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
  };
}
