{ config, lib, ... }:
let
  sites = config.services.ts1997.laravelSites;
in
{
  config = lib.mkIf (sites != { }) {
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

        serviceConfig = {
          Type = "oneshot";
          User = siteCfg.user;
          WorkingDirectory = siteCfg.workingDir;
          ExecStart = "${siteCfg.phpPool.fullPackage}/bin/php artisan schedule:run";
        };
      }
    ) sites;

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
    ) sites;
  };
}
