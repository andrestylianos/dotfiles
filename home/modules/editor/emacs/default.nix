{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hostConfig.editor.emacs;
in {
  options.hostConfig.editor.emacs = {
    enable = mkEnableOption "Emacs";
  };

  config = let
    emacsPkg = with pkgs;
      (emacsPackagesFor inputs.emacs-overlay.packages.${pkgs.hostPlatform.system}.emacsPgtk)
      .emacsWithPackages (ps: with ps; [vterm all-the-icons]);
    pathDeps = with pkgs; [
      #python3
      aspell
      binutils
      ripgrep
      fd
      gnutls
      zstd
      shfmt
      shellcheck
      sqlite
      editorconfig-core-c
      gcc
      jq

      nixfmt
    ];
    my-doom-emacs =
      emacsPkg
      // (pkgs.symlinkJoin {
        name = "my-doom-emacs";
        paths = [emacsPkg];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
              wrapProgram $out/bin/emacs \
                --prefix PATH : ${lib.makeBinPath pathDeps} \
                --set LSP_USE_PLISTS true \
          --set DOOMDIR ${config.xdg.configHome}/doom-config \
          --set DOOMLOCALDIR ${config.xdg.configHome}/doom-local \
          --add-flags "--init-directory ${config.xdg.configHome}/doom-emacs"
              wrapProgram $out/bin/emacsclient \
                --prefix PATH : ${lib.makeBinPath pathDeps} \
                --set LSP_USE_PLISTS true
        '';
      });
  in
    mkIf cfg.enable {
      home.packages = [my-doom-emacs];
      home = {
        sessionPath = ["${config.xdg.configHome}/doom-emacs/bin"];
        sessionVariables = {
          DOOMDIR = "${config.xdg.configHome}/doom-config";
          DOOMLOCALDIR = "${config.xdg.configHome}/doom-local";
        };
      };

      services.emacs = {
        enable = true;
        package = my-doom-emacs;
        client.enable = true;
        socketActivation.enable = true;
      };

      xdg = {
        enable = true;
        configFile = {
          "doom-config/config.el" = {
            source = ./config.el;
          };
          "doom-config/init.el" = {
            source = ./init.el;
            onChange = "${pkgs.writeShellScript "doom-init-change" ''
              export DOOMDIR="${config.home.sessionVariables.DOOMDIR}"
              export DOOMLOCALDIR="${config.home.sessionVariables.DOOMLOCALDIR}"
              export PATH=$PATH:$HOME/.nix-profile/bin
              ${config.xdg.configHome}/doom-emacs/bin/doom --force sync
            ''}";
          };
          "doom-config/packages.el" = {
            source = ./packages.el;
            onChange = "${pkgs.writeShellScript "doom-packages-change" ''
              export DOOMDIR="${config.home.sessionVariables.DOOMDIR}"
              export DOOMLOCALDIR="${config.home.sessionVariables.DOOMLOCALDIR}"
              export PATH=$PATH:$HOME/.nix-profile/bin
              ${config.xdg.configHome}/doom-emacs/bin/doom --force sync
            ''}";
          };
          "doom-emacs" = {
            source = inputs.doom-emacs-src;
            onChange = "${pkgs.writeShellScript "doom-change" ''
              export DOOMDIR="${config.home.sessionVariables.DOOMDIR}"
              export DOOMLOCALDIR="${config.home.sessionVariables.DOOMLOCALDIR}"
              export PATH=$PATH:$HOME/.nix-profile/bin
              if [ ! -d "$DOOMLOCALDIR" ]; then
                ${config.xdg.configHome}/doom-emacs/bin/doom --force install
              else
                ${config.xdg.configHome}/doom-emacs/bin/doom --force clean
                ${config.xdg.configHome}/doom-emacs/bin/doom --force sync -u
              fi
            ''}";
          };
        };
      };
    };
}
