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

  };

  outputs = { nixpkgs, home-manager, nur, doom-emacs-src, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          nur.overlay
        ];
      };

      lib = nixpkgs.lib;

    in {
      homeManagerConfigurations = {
        andre = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./users/andre/home.nix
          ];
          extraSpecialArgs = {
            doom-emacs-src = doom-emacs-src;
          };
        };
      };
      nixosConfigurations = {
        uruk = lib.nixosSystem{
          inherit system;

          modules = [
            ./system/configuration.nix
          ];
        };
      };
    };
}
