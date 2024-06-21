{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland = {
      # url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1&rev=a8ab1b1679e639ef23952f1a1d0834859d1c01b7";
    };
    hyprpicker = {
      url = "git+https://github.com/hyprwm/hyprpicker?submodules=1";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags.url = "github:Aylur/ags?rev=11150225e62462bcd431d1e55185e810190a730a";
    # nur.url = "github:nix-community/NUR";  
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };
  nixConfig = {
    extra-substituters = [
      # "https://nix-community.cachix.org"
      # "https://cache.nixos.org"
      # "https://cachix.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      # "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      # "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  outputs = { self, nixpkgs, ... } @inputs:
  {
    nixosConfigurations = {
      kamo-laptop = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs; 
          modules = "${self}/nixosModules";
          hmModules = "${self}/homeManagerModules";
        };
        modules = [
          ./hosts/laptop/configuration.nix
        ];
      };
      kamo-server = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          modules = "${self}/nixosModules";
          hmModules = "${self}/homeManagerModules";
          customPkgs = "${self}/nixosPackages";
        };
        modules = [
          ./hosts/server/configuration.nix
        ];
      };
      packages.x86_64-linux.default = nixpkgs.lib.mkDefault (self.nixosConfigurations.kamo-laptop.config.system.build.toplevel);
    };
  };
}
