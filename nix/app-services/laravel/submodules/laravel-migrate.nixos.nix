{
  config,
  lib,
  ...
}:
let
  sites = config.services.ts1997.laravelSites;

  # If we deploy as nix derivation, only then do we migrate via systemd service on server.
  sitesToMigrate = lib.filterAttrs (_: siteCfg: siteCfg.package != null && siteCfg.migrate.enable) sites;

  dbUnit = siteCfg: if siteCfg.database.driver == "pgsql" then "postgresql.service" else "mysql.service";
in
{
  config = lib.mkIf (sitesToMigrate != { }) {
    systemd.services = lib.mkMerge (
      (lib.mapAttrsToList (name: siteCfg: {
        "laravel-migrate-${name}" = {
          description = "Laravel migrations for ${siteCfg.appName}";
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
            ExecStart = "${siteCfg.phpPool.fullPackage}/bin/php artisan migrate --force";
          };
        };
      }) sitesToMigrate)
      # phpfpm's unit is created by the nixpkgs phpfpm module; extend it here
      # so it waits for migrations to finish rather than serving mismatched
      # code/schema.
      ++ (lib.mapAttrsToList (name: siteCfg: {
        "phpfpm-${name}" = {
          after = [ "laravel-migrate-${name}.service" ];
          wants = [ "laravel-migrate-${name}.service" ];
        };
      }) sitesToMigrate)
    );
  };
}
