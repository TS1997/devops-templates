{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.laravel.scheduler;
in
{
  options.services.ts1997.laravel.scheduler = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, config, ... }:
        {
          options = {
            user = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "User to run the scheduler as";
            };

            workingDir = lib.mkOption {
              type = lib.types.str;
              default = "/var/lib/${name}";
              description = "Working directory for the Laravel application";
            };

            phpPackage = lib.mkOption {
              type = lib.types.package;
              default = pkgs.php83;
              description = "PHP package to use";
            };

            appName = lib.mkOption {
              type = lib.types.str;
              description = "Application name";
            };
          };
        }
      )
    );
    default = { };
    description = "Laravel scheduler services";
  };

  config = lib.mkIf (cfg != { }) {
    systemd.services = lib.mapAttrs' (
      name: schedulerCfg:
      lib.nameValuePair "laravel-scheduler-${name}" {
        description = "Laravel Scheduler for ${schedulerCfg.appName}";
        after = [
          "network.target"
          "mysql.service"
          "phpfpm-${name}.service"
        ];
        wants = [
          "mysql.service"
          "phpfpm-${name}.service"
        ];

        serviceConfig = {
          Type = "oneshot";
          User = schedulerCfg.user;
          WorkingDirectory = schedulerCfg.workingDir;
          ExecStart = "${schedulerCfg.phpPackage}/bin/php artisan schedule:run";
        };
      }
    ) cfg;

    systemd.timers = lib.mapAttrs' (
      name: schedulerCfg:
      lib.nameValuePair "laravel-scheduler-${name}" {
        description = "Timer for ${schedulerCfg.appName} Scheduler";
        wantedBy = [ "timers.target" ];

        timerConfig = {
          OnCalendar = "*:0/1"; # Every minute
          Persistent = true;
          Unit = "laravel-scheduler-${name}.service";
        };
      }
    ) cfg;
  };
}
