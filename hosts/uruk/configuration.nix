{
  config,
  pkgs,
  inputs,
  system,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  hostConfig = {
    desktop = {
      hyprland.enable = true;
    };
    services = {
      paperless.enable = true;
    };
    shell = {
      default = "zsh";
    };
  };
}
