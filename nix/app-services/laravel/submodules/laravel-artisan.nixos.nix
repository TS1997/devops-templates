{
  config,
  lib,
  pkgs,
  ...
}:
let
  sites = lib.filterAttrs (_: siteCfg: siteCfg.enable) config.services.ts1997.laravelSites;

  mkArtisanForSite =
    name: siteCfg:
    pkgs.writeShellScriptBin "artisan-${name}" ''
      set -euo pipefail

      cd "${siteCfg.workingDir}"
      exec "${siteCfg.phpPool.fullPackage}/bin/php" artisan "$@"
    '';
in
{
  config = lib.mkIf (sites != { }) {
    users.users = lib.mkMerge (
      lib.mapAttrsToList (name: siteCfg: {
        ${siteCfg.user}.packages = [ (mkArtisanForSite name siteCfg) ];
      }) sites
    );
  };
}
