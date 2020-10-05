{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.setup.luks;
in
{
  options.setup.luks = {
    enable = mkEnableOption "luks setup";
  };
  
  config = mkIf cfg.enable {
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
    # LUKS Devices
    boot.initrd.luks.reusePassphrases = true;

    boot.initrd.luks.devices = {
      "cryptroot" = {
         device = "/dev/disk/by-label/cryptroot";
         allowDiscards = true;
       };
      "cryptswap" = {
        device = "/dev/disk/by-label/cryptswap";
        allowDiscards = true;
      };
      "cryptdata" = {
        device = "/dev/disk/by-label/cryptdata";
        allowDiscards = true;
      };
    };
  };
}
