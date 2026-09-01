{
  config,
  lib,
  ...
}:
let
  sites = config.services.ts1997.laravelSites;

  # Only package-deployed sites need this: rsync-deployed sites already run
  # "artisan optimize" from the CI deploy workflow instead.
  sitesToCleanse = lib.filterAttrs (_: siteCfg: siteCfg.package != null) sites;

  dbUnit = siteCfg: if siteCfg.database.driver == "pgsql" then "postgresql.service" else "mysql.service";
in
{
  config = lib.mkIf (sitesToCleanse != { }) {
    systemd.services = lib.mkMerge (
      (lib.mapAttrsToList (name: siteCfg: {
        "laravel-cleanse-${name}" = {
          description = "Cleanse cache and config for ${siteCfg.appName}";
          after = lib.optional siteCfg.database.enable (dbUnit siteCfg);
          wants = lib.optional siteCfg.database.enable (dbUnit siteCfg);
          before = [ "phpfpm-${name}.service" ];
          wantedBy = [ "multi-user.target" ];
          # Re-run on every deploy that ships new code, even though the unit
          # definition itself doesn't otherwise change between deploys.
          restartTriggers = [ siteCfg.package ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            User = siteCfg.user;
            WorkingDirectory = siteCfg.package;
            EnvironmentFile = "-${siteCfg.workingDir}/env";
            ExecStart = "${siteCfg.phpPool.fullPackage}/bin/php artisan optimize";
          };
        };
      }) sitesToCleanse)
      # phpfpm's unit is created by the nixpkgs phpfpm module; extend it here
      # so it waits for the cache/config warm-up to finish before serving
      # requests.
      ++ (lib.mapAttrsToList (name: siteCfg: {
        "phpfpm-${name}" = {
          after = [ "laravel-cleanse-${name}.service" ];
          wants = [ "laravel-cleanse-${name}.service" ];
        };
      }) sitesToCleanse)
    );
  };
}
