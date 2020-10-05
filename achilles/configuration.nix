# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  secrets = import ../secrets.nix;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../modules/luks.nix
      ../modules/zfs.nix
      ../modules/laptop.nix
    ];

  setup.luks.enable = true; 
  setup.zfs = {
    enable = true;
    hostId = "78ac4fde"; 
    importSafeguard = false;
    zfsRoot = true;
  };

  setup.laptop = {
    enable = true;
    gpu = "nvidia";
    wirelessNetworks = secrets.wifi.home;
    resumeDevice = "/dev/mapper/cryptswap";
  };

  networking.hostName = "achilles"; # Define your hostname.
  
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

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
        extraGroups = [ "wheel" ]; # Enable ‘sudo’
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

