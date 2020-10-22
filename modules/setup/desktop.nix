{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.setup.desktop;
in
{
  options.setup.desktop = {
    enable = mkEnableOption "desktop setup";
    gpu = mkOption {
      type = types.str;
      description = "Check the X11 drivers available for config.services.xserver.videoDrivers";
    };
  };
  config = mkIf cfg.enable {
    sound.enable = true;
    hardware.pulseaudio = {
      enable = true;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
      tcp = {
      enable = true;
      anonymousClients.allowedIpRanges = ["127.0.0.1"];
    };
  };

    hardware.bluetooth = {
      enable = true;
      config = {
        General = {
          Enable="Source,Sink,Media,Socket";
        };
      };
    };
    
    services.xserver = {
      enable = true;
      layout = "us";
      # Video Drivers for X11
      videoDrivers = [ cfg.gpu ];
      # Enable touchpad support.
      libinput.enable = true;
      displayManager = {
        lightdm.enable = true;
        defaultSession = "xsession";
        session = [
          {
            manage = "desktop";
            name = "xsession";
            start = "exec $HOME/.xsession";
          }
        ];
      };
    };

  };
}
