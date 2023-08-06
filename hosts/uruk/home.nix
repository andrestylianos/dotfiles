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
    direnv.enable = true;
    editor = {
      emacs.enable = true;
    };
    shell = {
      starship.enable = true;
      zsh.enable = true;
    };
  };
}
