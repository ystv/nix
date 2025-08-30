# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
# Just testing something

{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  locale = "en_GB.UTF-8";
  timezone = "Europe/London";
in
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [ "broadcast" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.enableAllTerminfo = true;

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

  networking.hostName = "ystv-remote-encoder"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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

  console.keyMap = "uk";

  users.users.broadcast = {
    isNormalUser = true;
    description = "Broadcast Account";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    ignoreShellProgramCheck = true;
    hashedPassword = "$y$j9T$Z6/JnpXpDqRCvgFs6O/Fq0$aVgg./1VNie8Gy7EKh0auuNp3e/NwEqjdJSmDuLLrJ/";
    shell = pkgs.zsh;
  };

  users.users.root.hashedPassword = "$y$j9T$uphD.j1c70afhycuLzw0B1$4xwBe7QHAgEfJHtXQIXtFiQTVuMSDPnwvHsQKFmtai8";

  services.getty.autologin = {
    enable = true;
    user = "broadcast";
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    dig
    speedtest-cli
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  system.stateVersion = "25.05";

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
}
