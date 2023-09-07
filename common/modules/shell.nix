{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkOption mkIf mkMerge types;
  cfg = config.hostConfig.shell;
in {
  options.hostConfig.shell = {
    default = mkOption {
      type = types.enum ["zsh"];
      description = "default shell";
    };
  };

  config = mkMerge [
    (mkIf (cfg.default == "zsh") {
      programs.zsh.enable = true;
      users.users.andre = {
        shell = pkgs.zsh;
      };
    })
  ];
}
