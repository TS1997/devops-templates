{ lib, util, ... }:
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
  };

  config = {
    scheduler.enable = lib.mkDefault true;
    queue.enable = lib.mkDefault true;
  };
}
