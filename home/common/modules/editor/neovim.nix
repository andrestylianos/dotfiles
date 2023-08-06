{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hostConfig.editor.neovim;
in {
  options.hostConfig.editor.neovim = {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      neovim
      lazygit
    ];

    home.sessionVariables.EDITOR = "nvim";
    programs.zsh.shellAliases = mkIf config.hostConfig.shell.zsh.enable {
      nvim-run = "nix run ~/coding/andrestylianos/neovim-flake/";
      nvim-develop = "nix develop ~/coding/andrestylianos/neovim-flake/";
    };
  };
}
