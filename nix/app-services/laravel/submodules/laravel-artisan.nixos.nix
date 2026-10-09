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
    let
      workingDir = siteCfg.appDir;
      envFile = "${siteCfg.workingDir}/env";
    in
    pkgs.writeShellScriptBin "artisan-${name}" ''
      set -euo pipefail

      cd "${workingDir}"
      ${lib.optionalString (siteCfg.package != null) ''
        if [ -f "${envFile}" ]; then
          set -a
          source "${envFile}"
          set +a
        fi
      ''}
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
