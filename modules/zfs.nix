{ lib, pkgs, config, ...}:
with lib;
let 
  cfg = config.setup.zfs;
in
{ 
  options.setup.zfs = {
    enable = mkEnableOption "zfs setup";
    hostId = mkOption {
      type = types.str;
      default = "01234567";
      };
    importSafeguard = mkOption {
      type = types.bool;
      default = false;
      description = "By default ZFS pools are forcefully imported. This turns off important safeguards. When a system is booting properly, enable safeguards, which turns off forced imports.";
      };
    snapshot = mkOption {
      type = types.bool;
      default = true;
      };
    zfsRoot = mkOption {
      type = types.bool;
      default = true;
      };
    };
    config = mkIf cfg.enable {
      boot.supportedFilesystems = [ (if cfg.zfsRoot then "zfs" else " ") ]; 
      # The 32-bit host id of the machine, formatted as 8 hexadecimal characters.
      # You should try to make this id unique among your machines.
      # This can be generated with the following command:
      # $ echo $(head -c4 /dev/urandom | od -A none -t x4 | cut -d ' ' -f 2)
      networking.hostId = cfg.hostId;

      # noop, the recommended elevator with zfs.
      # shell_on_fail allows to force import manually in the case of zfs import failure.
      boot.kernelParams = [ "elevator=noop" "boot.shell_on_fail" ];

      #  Turn off (false) forceImport options on a bootable system to ensure extra safeguards are active that zfs uses to protect zfs pools:
      
      boot.zfs.forceImportAll = !cfg.importSafeguard;
      boot.zfs.forceImportRoot = !cfg.importSafeguard;
      
      # Enables periodic scrubbing of ZFS pools.
      services.zfs.autoScrub.enable = true;
      # Enable the (OpenSolaris-compatible) ZFS auto-snapshotting service.
     # By default, the auto-snapshot service will keep the latest four 15-minute, 24 hourly, 7 daily, 4 weekly and 12 monthly snapshots.
     services.zfs.autoSnapshot = {
        enable = cfg.snapshot;
      # Change frequencies here:
      # frequent = 4;
      # hourly = 24;
      # daily = 7;
      # weekly = 4;
      # monthly = 12;
      };
    };
}

