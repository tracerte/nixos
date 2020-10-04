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
      ../modules/zfs.nix
      ../modules/laptop.nix
    ];

  # Use the grub EFI boot loader because it supports LUKS.
  boot.loader = {

    efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot";
	  };
    grub = {
             enable = true;
             version = 2;
             copyKernels = true;
             efiSupport = true;
	           device = "nodev"; 		
           };
  };

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
  };

  networking.hostName = "achilles"; # Define your hostname.
  
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
   i18n.defaultLocale = "en_US.UTF-8";
   console = {
     font = "Lat2-Terminus16";
     keyMap = "us";
   };

  # Set your time zone.
  time.timeZone = "America/New_York";
  
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ neovim ];
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
   };

   programs.zsh.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
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
  
  # Nix Store Maintenance
  nix.autoOptimiseStore = true;
  # Use gc.automatic to keep disk space under control.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
    };
  # Clean /tmp automatically on boot.
  boot.cleanTmpDir = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}

