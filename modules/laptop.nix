{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.setup.laptop;
in
{
  options.setup.laptop = {
    enable = mkEnableOption "laptop setup";
    wirelessNetworks = mkOption {
      type = types.attrs;
      example = {"MyNetwork".pskRaw="pskRaw generated";};
      };
    gpu = mkOption {
      type = types.str;
      description = "Check the X11 drivers available for config.services.xserver.videoDrivers";};
    resumeDevice = mkOption {
      type = types.str;
      example = "/dev/sda2";
    };
  };
    
  config = mkIf cfg.enable {
     boot.resumeDevice = cfg.resumeDevice;
     
     # Select internationalisation properties.
     i18n.defaultLocale = "en_US.UTF-8";
     console = {
      font = "Lat2-Terminus16";
       keyMap = "us";
     };

     # Set your time zone.
     time.timeZone = "America/New_York";

     # Allow unfree packages
     nixpkgs.config.allowUnfree = true;

     # List packages installed in system profile. To search, run:
     # $ nix search wget
     environment.systemPackages = with pkgs; [ neovim wpa_supplicant_gui ];

     programs.gnupg.agent = {
       enable = true;
     };
     programs.zsh.enable = true;

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

    # Power
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
     };
     services.upower.enable = true;
     networking.wireless = {
       enable = true;
       # Configuration for wpa_gui
       extraConfig = ''
         ctrl_interface=/run/wpa_supplicant
         ctrl_interface_group=wheel
	 '';
       networks = cfg.wirelessNetworks;
     };
     # Enable CUPS to print documents.
     services.printing.enable = true;

     # Enable sound.
     sound.enable = true;
     hardware.pulseaudio.enable = true;

     services.xserver = {
       enable = true;
       layout = "us";
       # Video Drivers for X11
       videoDrivers = [ cfg.gpu ];
       # Enable touchpad support.
       libinput.enable = true;
       displayManager.startx.enable = true;
    };
  };
}
