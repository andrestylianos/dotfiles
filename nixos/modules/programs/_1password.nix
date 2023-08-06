{
  options,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hostConfig.programs._1password;
in {
  options.hostConfig.programs._1password = {
    enable = mkEnableOption "1Password";
  };

  config = mkIf cfg.enable {
    programs = {
      _1password = {
        enable = true;
      };
      _1password-gui = {
        enable = true;
        polkitPolicyOwners = ["andre"];
      };
    };
  };
}
