args @ {
  pkgs,
  inputs,
  ...
}: {
  users.users.andre = {
    isHidden = "false";
    name = "andre";
    home = "/Users/andre";
    description = "Andre Stylianos Ramos";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = ["nix-command" "flakes" "auto-allocate-uids"];
    auto-optimise-store = true;

    substituters = [
      "https://andrestylianos.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "andrestylianos.cachix.org-1:KtVrGgFYfnzc/dVVx8Zn7RPLVsqwWzJ3NNfMllbXXEg="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  nix.gc = {
    automatic = true;
    interval = {Day = 7;};
    options = "--delete-older-than 7d";
  };
  nix.nixPath = ["flake:nixpkgs"];

  environment.systemPackages = with pkgs; [
    vim
    ripgrep
    gnupg
  ];

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    casks = [
      "altair-graphql-client"
      "amethyst"
      "font-jetbrains-mono-nerd-font"
      "gather"
      "iterm2"
      "logseq"
      "wezterm"
    ];
    brews = [
      "pinentry-mac"
    ];
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  security.pam.enableSudoTouchIdAuth = true;
  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
