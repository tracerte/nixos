{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.setup.printerScanner;
in
{
  imports = [
    <nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix>
  ];

  options.setup.printerScanner = {
    enable = mkEnableOption "printer and scanner setup";
    gui = mkOption {
      type = types.bool;
      default = true;
      description = "Is the system using X or Wayland";
    };
  };
  config = mkIf cfg.enable {

    # Enable CUPS to print documents.
    services.printing = {
      enable = true;
      drivers = with pkgs; [ brlaser ];
    };

    # Enable Scanning
    hardware.sane = {
      enable = true;
      brscan4 = {
        enable = true;
        netDevices = {
          home = { model = "DCP-7065DN"; ip = "192.168.1.163"; };
        };
      };
    };

    environment.systemPackages = with pkgs; mkIf cfg.gui [ system-config-printer xsane gscan2pdf ];
  };
}
