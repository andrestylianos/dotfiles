{
  description = "System config flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";

    doom-emacs-src = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
      };
    };
    my-neovim.url = "github:andrestylianos/neovim-flake";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    hyprland,
    sops-nix,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    lib = nixpkgs.lib;
  in {
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
    nixosConfigurations = {
      uruk = lib.nixosSystem {
        inherit system;

        modules = [
          ./hosts/uruk/configuration.nix
          ./nixos
          hyprland.nixosModules.default
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.andre = import ./users/andre/home.nix;

            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
            home-manager.sharedModules = [
              hyprland.homeManagerModules.default
              ./hosts/uruk/home.nix
              ./home/modules
            ];
          }
        ];

        specialArgs = {
          inherit inputs;
        };
      };
    };
  };
}
