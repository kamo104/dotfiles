{
  description = "Nixos config flake";

  inputs = {
    # hyprland = {
    #   url = "github:hyprwm/Hyprland";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    # nixpkgs.url = "tarball+https://codeload.github.com/NixOS/nixpkgs/tar.gz/b47fd6fa00c6afca88b8ee46cfdb00e104f50bca";

    home-manager = {
      url = "github:nix-community/home-manager";
      # url = "tarball+https://codeload.github.com/nix-community/home-manager/tar.gz/1395379a7a36e40f2a76e7b9936cc52950baa1be";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      # url = "github:aylur/ags";
      url = "tarball+https://codeload.github.com/Aylur/ags/tar.gz/27cd93147aba09142fa585fd16f13c56268b696c";
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
    # home manager configuration for non nixos systems
    homeConfigurations = {
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
