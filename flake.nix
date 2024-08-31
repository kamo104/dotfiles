{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      # url = "git+https://github.com/hyprwm/Hyprland?submodules=1&rev=a8ab1b1679e639ef23952f1a1d0834859d1c01b7";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpicker = {
      url = "git+https://github.com/hyprwm/hyprpicker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nur.url = "github:nix-community/NUR";  
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };
  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  outputs = { self, nixpkgs, ... } @inputs:
  let 
    modules = "${self}/nixosModules";
    hmModules = "${self}/homeManagerModules";
    customPkgs = "${self}/nixosPackages";
  in
  {
    nixosConfigurations = {
      kamo-laptop = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs modules hmModules customPkgs;
          hostname = "kamo-laptop";
        };
        modules = [
          ./hosts/laptop/configuration.nix
        ];
      };
      kamo-server = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs modules hmModules customPkgs;
          hostname = "kamo-server";
        };
        modules = [
          ./hosts/server/configuration.nix
        ];
      };
    };
    
    # base nix profile system packages for non nixos systems
    packages."x86_64-linux"."work-laptop" = 
    let 
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in
      pkgs.buildEnv{
        name = "work-laptop";
        paths = import "${modules}/common-pkgs.nix" {inherit pkgs;};
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
