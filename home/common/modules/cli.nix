{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hostConfig.cli;
in {
  options.hostConfig.cli = {
    enable = mkEnableOption "cli";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      exa
      fd
      ripgrep
      tldr
    ];

    programs.fzf = {
      enable = true;
      enableZshIntegration = config.hostConfig.shell.zsh.enable;
    };
    programs.bat = {
      enable = true;
    };
    programs.zsh.shellAliases = mkIf config.hostConfig.shell.zsh.enable {
      ls = "exa";
      cat = "bat";
    };
  };
}
