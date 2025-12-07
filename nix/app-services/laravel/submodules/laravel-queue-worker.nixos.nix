{ config, lib, ... }:
let
  sites = config.services.ts1997.laravelSites;
  queueSites = lib.filterAttrs (name: siteCfg: siteCfg.queue.enable) sites;
in
{
  config = lib.mkIf (queueSites != { }) {
    systemd.services = lib.mkMerge (
      lib.mapAttrsToList (
        name: siteCfg:
        lib.listToAttrs (
          lib.genList (
            worker:
            lib.nameValuePair "laravel-queue-worker-${name}-${toString (worker + 1)}" {
              description = "Laravel Queue Worker ${toString (worker + 1)} for ${siteCfg.appName}";
              after = [
                "network.target"
                "phpfpm-${name}.service"
              ]
              ++ lib.optionals (siteCfg.queue.connection == "redis") [ "redis.service" ];
              wants = [
                "phpfpm-${name}.service"
              ]
              ++ lib.optionals (siteCfg.queue.connection == "redis") [ "redis.service" ];
              wantedBy = [ "multi-user.target" ];

              serviceConfig = {
                Type = "simple";
                User = siteCfg.user;
                Group = siteCfg.user;
                WorkingDirectory = siteCfg.workingDir;
                Restart = "always";
                RestartSec = 10;

                ExecStart = ''
                  ${siteCfg.phpPool.fullPackage}/bin/php artisan queue:work ${siteCfg.queue.connection} \
                    --timeout=${toString siteCfg.queue.timeout} \
                    --sleep=${toString siteCfg.queue.sleep} \
                    --tries=${toString siteCfg.queue.tries} \
                    --max-jobs=${toString siteCfg.queue.maxJobs} \
                    --max-time=${toString siteCfg.queue.maxTime}
                '';
              };
            }
          ) siteCfg.queue.workers
        )
      ) queueSites
    );
  };
}
