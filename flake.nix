{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    # hyprland = {
    #   url = "github:hyprwm/Hyprland";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ags = {
    #   url = "github:aylur/ags";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
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
