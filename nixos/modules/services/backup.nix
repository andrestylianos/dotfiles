{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hostConfig.services.backup;
in {
  options.hostConfig.services.backup = {
    enable = mkEnableOption "Restic backup service";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [restic];
    sops.secrets.ars-backup-password = {
      format = "binary";
      sopsFile = ../../../secrets/ars-backup-password.txt;
    };

    sops.secrets.ars-api-key = {
      format = "dotenv";
      sopsFile = ../../../secrets/ars-api-key.env;
    };
  };
}
