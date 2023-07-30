{
  config,
  pkgs,
  inputs,
  system,
  ...
}: {
  hostConfig = {
    desktop = {
      hyprland.enable = true;
    };
    editor = {
      emacs.enable = true;
    };
    shell = {
      zsh.enable = true;
    };
  };
}
