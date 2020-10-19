{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.setup.nixStore;
in
{
  options.setup.nixStore = {
    enable = mkEnableOption "nix store setup";
  };

  config = mkIf cfg.enable {
    # Protect nix-shell from GC
    nix.extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      '';
    # Nix Store Maintenance
    nix.autoOptimiseStore = true;
    # Use gc.automatic to keep disk space under control.
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
