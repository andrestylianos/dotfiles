{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hostConfig.desktop.hyprland;
in {
  options.hostConfig.desktop.hyprland = {
    enable = mkEnableOption "Hyprland desktop";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unstable.qt5.qtwayland
      unstable.qt6.qtwayland
      libsForQt5.polkit-kde-agent
      plasma5Packages.ksshaskpass
      plasma5Packages.kwallet
      plasma5Packages.kwalletmanager
      plasma5Packages.kwallet-pam
    ];

    nix.settings = {
      substituters = [
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    programs.hyprland.enable = true;
  };
}
