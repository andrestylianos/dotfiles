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
      neovim.enable = true;
      emacs.enable = true;
    };
    shell = {
      starship.enable = true;
      zsh.enable = true;
    };
  };
}
