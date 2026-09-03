{
  config,
  lib,
  pkgs,
  ...
}:
let
  sites = config.services.ts1997.laravelSites;

  mkArtisanForSite =
    siteCfg:
    let
      workingDir = if siteCfg.package != null then siteCfg.package else siteCfg.workingDir;
      envFile = "${siteCfg.workingDir}/env";
    in
    pkgs.writeShellScriptBin "artisan" ''
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
      lib.mapAttrsToList (_: siteCfg: {
        ${siteCfg.user}.packages = [ (mkArtisanForSite siteCfg) ];
      }) sites
    );
  };
}
