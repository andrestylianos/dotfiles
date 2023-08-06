{
  options,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hostConfig.direnv;
in {
  options.hostConfig.direnv = {
    enable = mkEnableOption "direnv";
  };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableZshIntegration = config.hostConfig.shell.zsh.enable;
      nix-direnv.enable = true;
    };
  };
}
