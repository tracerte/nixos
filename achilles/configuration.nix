# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../modules/setup/luks.nix
      ../modules/setup/zfs.nix
      ../modules/setup/printer-scanner.nix
      ../modules/setup/wifi.nix
      ../modules/setup/nix-opts.nix
      ../modules/setup/desktop.nix
      ../modules/setup/power-scaling.nix
    ];

  setup.luks = {
    enable = true;
    hibernation = true;
  };
  setup.zfs = {
    enable = true;
    hostId = "78ac4fde";
    importSafeguard = true;
    zfsRoot = true;
  };

  setup.printerScanner = {
    enable = true;
    gui = true;
  };

  setup.wifi = {
    enable = true;
    gui = true;
    wirelessNetworks = secrets.wifi.home;
  };

  setup.nixOpts.enable = true;

  setup.desktop = {
    enable = true;
    gpu = "nvidia";
  };

  setup.powerScaling.enable = true;

  networking.hostName = "achilles"; # Define your hostname.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  services.openssh.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "ter-powerline-v20b";
    packages = [ pkgs.powerline-fonts ];
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ vim nixpkgs-fmt ];

  programs.gnupg.agent = {
    enable = true;
  };
  programs.zsh.enable = true;

  # Clean /tmp automatically on boot.
  boot.cleanTmpDir = true;


  users = {
    groups = {
      tracerte = { gid = 1000; };
    };
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users = {
      tracerte = {
        isNormalUser = true;
        createHome = true;
        home = "/home/tracerte";
        description = "Matthew B. Reisch";
        uid = 1000;
        group = "tracerte";
        extraGroups = [ "wheel" "scanner" "lp" "sound" "audio" "video" ]; # Enable ‘sudo’
        # Create password with $ mkpasswd -m sha-512
        hashedPassword = secrets.tracerte.hashedPassword;
        openssh.authorizedKeys.keys = secrets.tracerte.sshKeys;
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}
