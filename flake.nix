{
  description = "System config flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
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
  };

  outputs = {
    nixpkgs,
    home-manager,
    nur,
    doom-emacs-src,
    hyprland,
    nixpkgs-unstable,
    hyprland-contrib,
    emacs-overlay,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    overlay-unstable = final: prev: {
      # use this variant if unfree packages are needed:
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    };

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
      overlays = [
        nur.overlay
        overlay-unstable
      ];
    };

    lib = nixpkgs.lib;
  in {
    formatter.${system} = pkgs.alejandra;
    homeManagerConfigurations = {
      andre = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./users/andre/home.nix
          hyprland.homeManagerModules.default
        ];
        extraSpecialArgs = {
          doom-emacs-src = doom-emacs-src;
          hyprland = hyprland;
          hyprland-contrib = hyprland-contrib;
          emacs-overlay = emacs-overlay;
        };
      };
    };
    nixosConfigurations = {
      uruk = lib.nixosSystem {
        inherit pkgs system;

        modules = [
          ./system/configuration.nix

          hyprland.nixosModules.default
        ];

        specialArgs = {inherit inputs;};
      };
    };
  };
}
