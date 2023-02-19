{ config, pkgs, ... }:

let
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/nix-community/nix-doom-emacs/archive/master.tar.gz;
  }) {
    doomPrivateDir = ../../config/.doom.d;  # Directory containing your config.el, init.el
    # and packages.el files
  };

in {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "andre";
  home.homeDirectory = "/home/andre";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  home = {
    sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];
    sessionVariables = {
      DOOMDIR = "${config.xdg.configHome}/doom-config";
      DOOMLOCALDIR = "${config.xdg.configHome}/doom-local";
    };
  };

  home.file.".test".source = ../../config/.test ;

  fonts.fontconfig.enable = true;

  programs.git = {
    enable = true;
    userName = "André Stylianos Ramos";
    userEmail = "andre.stylianos@protonmail.com";
    extraConfig = {
      user = {
        signingkey = "A6DDF756C510CB4E";
      };
      commit = {
        gpgsign = true;
      };
    };
  };

  programs.gpg = {
    enable = true;
  };

  services.emacs.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "qt";
  };

  home.packages = with pkgs; [
    doom-emacs
    git
    git-crypt
    gnupg
    pinentry-qt
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  xdg = {
    enable = true;
    configFile = {
      "doom-config/config.el".source = ../../config/.doom.d/config.el;
      "doom-config/init.el".source = ../../config/.doom.d/init.el;
      "doom-config/packages.el".source = ../../config/.doom.d/packages.el;


      "gtk-4.0/settings.ini".source = ../../config/gtk-4.0/settings.ini;
     };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
