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
    };
  config = mkIf cfg.enable {
    # Power
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
     };
     services.upower.enable = true;
     environment.systemPackages = [ pkgs.wpa_supplicant_gui ]; 
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
