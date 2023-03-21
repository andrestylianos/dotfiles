# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  networking.hostName = "uruk";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  services.dbus.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "alt-intl";
    enable = true;
    videoDrivers = ["amdgpu"];

    # KDE Plasma 5
    #displayManager.lightdm = {
    #  enable = true;
    #};
    # desktopManager.plasma5.enable = true;

    #GNOME
    displayManager.gdm.enable = true;
    #desktopManager.gnome.enable = false;
  };

  programs.dconf.enable = true;
  programs.gnome-disks.enable = true;
  services.udisks2.enable = true;
  #services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  #environment.gnome.excludePackages = (with pkgs; [
  #gnome-photos
  #gnome-tour
  #]) ++ (with pkgs.gnome; [
  #  cheese # webcam tool
  #  gnome-music
  #  gnome-terminal
  #  gedit # text editor
  #  epiphany # web browser
  #  geary # email reader
  #  evince # document viewer
  #  gnome-characters
  #  totem # video player
  #  tali # poker game
  #  iagno # go game
  #  hitori # sudoku game
  #  atomix # puzzle game
  #]);

  programs.zsh.enable = true;

  programs.steam = {
    enable = true;
  };

  services.emacs = {
    enable = true;
    package = pkgs.emacs; # replace with emacs-gtk, or a version provided by the community overlay if desired.
  };

  # Configure console keymap
  # console.keyMap = "us";
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  #environment.etc = {
  #  "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
  #  bluez_monitor.properties = {
  #    ["bluez5.enable-sbc-xq"] = true,
  #    ["bluez5.enable-msbc"] = true,
  #    ["bluez5.enable-hw-volume"] = true,
  #    ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
  #                                                  }
  #'';
  #};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.andre = {
    isNormalUser = true;
    description = "André Ramos";
    extraGroups = ["networkmanager" "wheel" "podman"];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];

    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    #gnome.gnome-tweaks
    # firefox
    ## Hyprland
    unstable.qt5.qtwayland
    unstable.qt6.qtwayland
    libsForQt5.polkit-kde-agent
    plasma5Packages.ksshaskpass
    plasma5Packages.kwallet
    plasma5Packages.kwalletmanager
    plasma5Packages.kwallet-pam
    ## Docker
    arion
    docker-client
  ];

  programs.hyprland.enable = true;

  #  xdg = {
  #    portal = {
  #      enable = true;
  #      extraPortals = with pkgs; [
  #        xdg-desktop-portal-wlr
  #        xdg-desktop-portal-gnome
  #      ];
  #      gtkUsePortal = true;
  #    };
  #  };

  security = {
    pam.services = {
      login.enableKwallet = true;
      gdm.enableKwallet = true;
      kdm.enableKwallet = true;
      lightdm.enableKwallet = true;
      sddm.enableKwallet = true;

      swaylock = {
        text = "auth include login";
      };
    };
    polkit = {
      enable = true;
    };
  };

  programs.ssh = {
    startAgent = true;
    askPassword = "${pkgs.plasma5Packages.ksshaskpass.out}/bin/ksshaskpass";

    extraConfig = ''
      AddKeysToAgent yes
    '';
  };

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  # For 32 bit applications
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [
    amdvlk
  ];
  # For 32 bit applications
  # Only available on unstable
  hardware.opengl.extraPackages32 = with pkgs; [
    driversi686Linux.amdvlk
  ];

  # Remove sound.enable or turn it off if you had it set previously, it seems to cause conflicts with pipewire
  sound.enable = false;
  hardware.pulseaudio.enable = false;

  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    media-session.config.bluez-monitor.rules = [
      {
        # Matches all cards
        matches = [{"device.name" = "~bluez_card.*";}];
        actions = {
          "update-props" = {
            "bluez5.reconnect-profiles" = ["hfp_hf" "hsp_hs" "a2dp_sink"];
            # mSBC is not expected to work on all headset + adapter combinations.
            "bluez5.msbc-support" = true;
            # SBC-XQ is not expected to work on all headset + adapter combinations.
            "bluez5.sbc-xq-support" = true;
          };
        };
      }
      {
        matches = [
          # Matches all sources
          {"node.name" = "~bluez_input.*";}
          # Matches all outputs
          {"node.name" = "~bluez_output.*";}
        ];
      }
    ];
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  ############
  # Docker
  ############

  # Arion works with Docker, but for NixOS-based containers, you need Podman
  # since NixOS 21.05.
  virtualisation.docker.enable = false;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.defaultNetwork.dnsname.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #	 pinentryFlavor = null;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
