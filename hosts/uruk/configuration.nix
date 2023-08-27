{
  config,
  pkgs,
  inputs,
  system,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  hostConfig = {
    desktop = {
      hyprland.enable = true;
    };
    programs = {
      _1password.enable = true;
    };
    services = {
      backup.enable = true;
      paperless.enable = true;
    };
    shell = {
      default = "zsh";
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  networking.hostName = "uruk";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  programs.steam = {
    enable = true;
  };

  services.tailscale.enable = true;

  # Configure console keymap
  # console.keyMap = "us";
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
                                                      }
    '';
  };

  users.users.andre = {
    extraGroups = ["networkmanager" "wheel" "podman"];
  };

  nixpkgs.overlays = [
    inputs.nur.overlay
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    #gnome.gnome-tweaks
    # firefox
    ## Docker
    arion
    docker-client
    unstable.logseq
  ];

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
    pam.u2f = {
      enable = true;
      cue = true;
    };
    pam.services = {
      login.enableKwallet = true;
      gdm.enableKwallet = true;
      kdm.enableKwallet = true;
      lightdm.enableKwallet = true;
      sddm.enableKwallet = true;
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      polkit-1.u2fAuth = true;

      swaylock = {
        text = "auth include login";
      };
    };
    polkit = {
      enable = true;
    };
  };

  sops.age.keyFile = "/home/andre/.config/sops/age/keys.txt";
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
    #amdvlk
    rocm-opencl-icd
    rocm-opencl-runtime
  ];
  # For 32 bit applications
  # Only available on unstable
  hardware.opengl.extraPackages32 = with pkgs; [
    #driversi686Linux.amdvlk
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
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

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
  #
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";

    trustedInterfaces = [config.services.tailscale.interfaceName];
    allowedTCPPorts = [
      7860 # stable-diffusion
      28981 # Paperless
      config.services.tailscale.port
    ];
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
    allowedUDPPorts = [
      7860 # stable-diffusion
      28981 # Paperless
      config.services.tailscale.port
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
