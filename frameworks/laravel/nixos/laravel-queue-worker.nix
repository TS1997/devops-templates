{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.laravel.queue;
in
{
  options.services.ts1997.laravel.queue = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, config, ... }:
        {
          options = {
            user = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "User to run the queue worker as";
            };

            workingDir = lib.mkOption {
              type = lib.types.str;
              default = "/var/lib/${name}";
              description = "Working directory for the Laravel application";
            };

            phpPackage = lib.mkOption {
              type = lib.types.package;
              default = pkgs.php;
              description = "PHP package to use";
            };

            appName = lib.mkOption {
              type = lib.types.str;
              description = "Application name";
            };

            connection = lib.mkOption {
              type = lib.types.str;
              default = "redis";
              description = "Queue name to process";
            };

            workers = lib.mkOption {
              type = lib.types.int;
              default = 8;
              description = "Number of queue worker instances";
            };

            timeout = lib.mkOption {
              type = lib.types.int;
              default = 60;
              description = "Maximum number of seconds a job may run";
            };

            sleep = lib.mkOption {
              type = lib.types.int;
              default = 3;
              description = "Number of seconds to sleep when no job is available";
            };

            tries = lib.mkOption {
              type = lib.types.int;
              default = 3;
              description = "Number of times to attempt a job before logging it failed";
            };

            maxJobs = lib.mkOption {
              type = lib.types.int;
              default = 1000;
              description = "Maximum number of jobs to process before restarting";
            };

            maxTime = lib.mkOption {
              type = lib.types.int;
              default = 3600;
              description = "Maximum number of seconds a worker may live";
            };
          };
        }
      )
    );
    default = { };
    description = "Laravel queue worker services";
  };

  config = lib.mkIf (cfg != { }) {
    systemd.services = lib.mkMerge (
      lib.mapAttrsToList (
        name: queueCfg:
        lib.listToAttrs (
          lib.genList (
            i:
            lib.nameValuePair "laravel-queue-${name}-${toString i}" {
              description = "Laravel Queue Worker ${toString i} for ${queueCfg.appName}";
              after = [ "network.target" ];
              wantedBy = [ "multi-user.target" ];

              serviceConfig = {
                Type = "simple";
                User = queueCfg.user;
                Group = queueCfg.user;
                WorkingDirectory = queueCfg.workingDir;

                ExecStart = ''
                  ${queueCfg.phpPackage}/bin/php artisan queue:work ${queueCfg.connection} \
                    --timeout=${toString queueCfg.timeout} \
                    --sleep=${toString queueCfg.sleep} \
                    --tries=${toString queueCfg.tries} \
                    --max-jobs=${toString queueCfg.maxJobs} \
                    --max-time=${toString queueCfg.maxTime}
                '';

                Restart = "on-failure";
                RestartSec = "5s";
              };
            }
          ) queueCfg.workers
        )
      ) cfg
    );
  };
}
