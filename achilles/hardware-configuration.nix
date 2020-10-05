# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "thinkpad_acpi" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "zroot/ROOT/nixos";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "zroot/NIX/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "zroot/HOME/home";
      fsType = "zfs";
    };

  fileSystems."/tmp" =
    { device = "zroot/TMP/tmp";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
    };
    
  fileSystems."/backup" =
    { device = "zdata/BACKUP/backup";
      fsType = "zfs";
    };

  # Swap
  swapDevices = [ { device = "/dev/mapper/cryptswap"; } ];
  
  nix.maxJobs = lib.mkDefault 8;
}
