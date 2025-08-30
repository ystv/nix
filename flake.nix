{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      agenix,
      ...
    }:
    let
      inherit (nixpkgs.lib) nixosSystem mapAttrs;

      system = "x86_64-linux";

      stable-pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      sharedArgs = {
        inherit stable-pkgs;
        inherit system;
        inherit inputs;
        inherit agenix;
      };

      commonModules = [
        # home-manager.nixosModules.home-manager
        agenix.nixosModules.default
      ];
    in
    rec {
      nixosConfigurations = {
        nix-builder = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = sharedArgs;
          modules = commonModules ++ [
            {
              nixpkgs.pkgs = stable-pkgs;
            }
            ./nix-builder
          ];
        };

        remote-encoder = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = sharedArgs;
          modules = commonModules ++ [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
            {
              nixpkgs.pkgs = stable-pkgs;
            }
            ./remote-encoder
          ];
        };
      };
    };
}
