{
  description = "System config flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {...}:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      flake = {
        nixosConfigurations = {
          uruk = inputs.nixpkgs.lib.nixosSystem {
            modules = [
              ./hosts/uruk/configuration.nix
              ./common
              ./nixos
              inputs.hyprland.nixosModules.default
              inputs.home-manager.nixosModules.home-manager
              inputs.sops-nix.nixosModules.sops
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.andre = import ./nixos/home.nix;

                home-manager.extraSpecialArgs = {
                  inherit inputs;
                };
                home-manager.sharedModules = [
                  inputs.hyprland.homeManagerModules.default
                  ./hosts/uruk/home.nix
                  ./home/common/modules
                  ./home/nixos/modules
                ];
              }
            ];

            specialArgs = {
              inherit inputs;
            };
          };
        };
        darwinConfigurations."DN2J7HMQ7T" = inputs.nix-darwin.lib.darwinSystem {
          modules = [
            # ./hosts/whale-macbook/configuration.nix
            ./darwin
            ./common
            inputs.home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.andre = import ./darwin/home.nix;

              home-manager.extraSpecialArgs = {
                inherit inputs;
              };
              home-manager.sharedModules = [
                ./hosts/whale-macbook/home.nix
                ./home/common/modules
                #./home/darwin/modules
              ];
            }
          ];
          specialArgs = {inherit inputs;};
        };
      };
      perSystem = {
        pkgs,
        inputs,
        ...
      }: {
        formatter = pkgs.alejandra;
      };
    };
}
