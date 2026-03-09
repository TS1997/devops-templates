{
  config,
  lib,
  pkgs,
  ...
}:
let
  sites = config.services.ts1997.laravelSites;
  schedulerSites = lib.filterAttrs (name: siteCfg: siteCfg.scheduler.enable) sites;

  dbPackage =
    siteCfg:
    if siteCfg.database.enable then
      (
        if siteCfg.database.driver == "pgsql" then
          [ config.services.ts1997.pgsql.package ]
        else
          [ config.services.ts1997.mysql.package ]
      )
    else
      [ ];

  mkPackages =
    siteCfg:
    with pkgs;
    [
      gzip
      gnutar
      siteCfg.phpPool.fullPackage
    ]
    ++ dbPackage siteCfg
    ++ siteCfg.scheduler.packages;
in
{
  config = lib.mkIf (schedulerSites != { }) {
    systemd.services = lib.mapAttrs' (
      name: siteCfg:
      lib.nameValuePair "laravel-scheduler-${name}" {
        description = "Laravel Scheduler for ${siteCfg.appName}";
        after = [
          "network.target"
          "phpfpm-${name}.service"
        ];
        wants = [ "phpfpm-${name}.service" ];
        wantedBy = [ "multi-user.target" ];

        path = mkPackages siteCfg;

        serviceConfig = {
          Type = "oneshot";
          User = siteCfg.user;
          WorkingDirectory = siteCfg.workingDir;
          ExecStart = "${siteCfg.phpPool.fullPackage}/bin/php artisan schedule:run";
        };
      }
    ) schedulerSites;

    systemd.timers = lib.mapAttrs' (
      name: siteCfg:
      lib.nameValuePair "laravel-scheduler-${name}" {
        description = "Timer for ${siteCfg.appName} Scheduler";
        wantedBy = [ "timers.target" ];

        timerConfig = {
          OnCalendar = "*:0/1"; # every minute
          Persistent = true;
          Unit = "laravel-scheduler-${name}.service";
        };
      }
    ) schedulerSites;
  };
}
