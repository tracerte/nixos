{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.setup.powerScaling;
in
{
  options.setup.powerScaling = {
    enable = mkEnableOption "power scaling setup";
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
  };
}
