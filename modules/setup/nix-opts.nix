{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.setup.nixOpts;
in
{
  options.setup.nixOpts = {
    enable = mkEnableOption "nix options setup";
  };

  config = mkIf cfg.enable {
    nix = {
      # Protect nix-shell from GC with
      # keep-outputs and  keep-derivations
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
      '';
      # Nix Store Maintenance
      autoOptimiseStore = true;
      # Use gc.automatic to keep disk space under control.
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };
  };
}
