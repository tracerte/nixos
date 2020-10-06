{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.setup.wifi;
in
{
  options.setup.wifi = {
    enable = mkEnableOption "wifi setup";
    wirelessNetworks = mkOption {
      type = types.attrs;
      example = { "MyNetwork".pskRaw = "pskRaw generated"; };
    };
    gui = mkOption {
      type = types.bool;
      default = true;
      description = "Is the system using X or Wayland";
    };

  };
  config = mkIf cfg.enable {
    networking.wireless = {
      enable = true;
      # Configuration for wpa_gui
      extraConfig = ''
        ctrl_interface=/run/wpa_supplicant
        ctrl_interface_group=wheel
      '';
      networks = cfg.wirelessNetworks;
    };

    environment.systemPackages = with pkgs; mkIf cfg.gui [ wpa_supplicant_gui ];
  };
}
