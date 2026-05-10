{
  config,
  lib,
  util,
  pkgs,
  ...
}:
{
  options = {
    scheduler.enable = lib.mkEnableOption "Enable Laravel Scheduler";

    queue = lib.mkOption {
      type = util.submodule {
        options = {
          enable = lib.mkEnableOption "Enable Laravel Queue Worker for the application.";

          connection = lib.mkOption {
            type = lib.types.enum [
              "redis"
              "database"
            ];
            default = "redis";
            description = "The queue connection to use.";
          };

          workers = lib.mkOption {
            type = lib.types.int;
            default = 8;
            description = "Number of queue worker processes to run.";
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
      };
      default = { };
      description = "Laravel Queue Worker configuration.";
    };

    inertiaSsr = lib.mkOption {
      type = util.submodule {
        options = {
          enable = lib.mkEnableOption "Enable Inertia.js Server-Side Rendering server.";

          host = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "The host the Inertia SSR server binds to.";
          };

          port = lib.mkOption {
            type = lib.types.int;
            default = 13714;
            description = "The port the Inertia SSR server listens on.";
          };
        };
      };
      default = { };
      description = "Inertia.js SSR configuration.";
    };
  };

  config = {
    inertiaSsr.enable = lib.mkDefault true;
    scheduler.enable = lib.mkDefault true;
    queue.enable = lib.mkDefault true;
    database.package = lib.mkDefault (
      if config.database.driver == "pgsql" then pkgs.postgresql_18 else pkgs.mysql84
    );
  };
}
