# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  locale = "en_GB.UTF-8";
  timezone = "Europe/London";

  toml = pkgs.formats.toml { };

  spotifydSrc = pkgs.fetchFromGitHub {
    owner = "Spotifyd";
    repo = "spotifyd";
    rev = "77337ec42dc7f86d0002dd06f172fd9c0c9ebc5c";
    hash = "sha256-RucpAIQ3/U5qrxydKkHUrfVbP7hwFIFfnxZ3pCIgSww=";
  };

  spotifyd = pkgs.spotifyd.overrideAttrs (oldAttrs: {
    src = spotifydSrc;
    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      src = spotifydSrc;
      hash = "sha256-mxH/vpA7mA5qobWtscic/jnJCVmX7J9kzeOqQWnu588=";
    };
  });

  spotifydConf = toml.generate "spotify.conf" {
    global = {
      device_name = "Samsung Smart Fridge";
      dbus_type = "system";
      zeroconf_port = 6969;
      use_mpris = false;
      backend = "pipe";
    };
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.trusted-users = [ "broadcast" ];

  users.users.root.openssh.authorizedKeys.keys = [
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKbv0CfhD/1mE+OORtFtHcj9PA3Gal6S/+czXp82B0t archessmn@macbook''
  ];

  security.sudo.extraRules = [
    {
      users = [ "broadcast" ];
      runAs = "ALL:ALL";
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nix-builder"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  time.timeZone = "${timezone}";

  # Select internationalisation properties
  i18n.defaultLocale = "${locale}";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "${locale}";
    LC_IDENTIFICATION = "${locale}";
    LC_MEASUREMENT = "${locale}";
    LC_MONETARY = "${locale}";
    LC_NAME = "${locale}";
    LC_NUMERIC = "${locale}";
    LC_PAPER = "${locale}";
    LC_TELEPHONE = "${locale}";
    LC_TIME = "${locale}";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = "broadcast";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.broadcast = {
    isNormalUser = true;
    description = "Broadcast";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # services.spotifyd = {
  #   enable = true;
  #   package = spotifyd;
  #   settings = {
  #     global = {
  #       device_name = "Samsung Smart Fridge";
  #       dbus_type = "system";
  #       zeroconf_port = 6969;
  #       use_mpris = false;
  #     };
  #   };
  # };

  systemd.services.spotifyd = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "sound.target"
    ];
    description = "spotifyd, a Spotify playing daemon";
    environment.SHELL = "/bin/sh";
    serviceConfig = {
      ExecStart = "${spotifyd}/bin/spotifyd --no-daemon --cache-path /var/cache/spotifyd --config-path ${spotifydConf}";
      Restart = "always";
      RestartSec = 12;
      CacheDirectory = "spotifyd";
      SupplementaryGroups = [ "audio" ];
    };
  };

  networking.firewall.allowedUDPPorts = [ 5353 ];
  networking.firewall.allowedTCPPorts = [ 6969 ];

  # Install firefox.
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    vlc
  ];

  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
