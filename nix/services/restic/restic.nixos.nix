{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ts1997.restic;

  # Database dumps are written here right before each run and removed again
  # afterwards, so they end up in the snapshot next to the job's paths.
  dumpDir = name: "/var/backup/restic-dumps/${name}";

  dumpCommand =
    name: db:
    let
      file = lib.escapeShellArg "${dumpDir name}/${db.name}.${db.driver}.sql";
      dbName = lib.escapeShellArg db.name;
    in
    if db.driver == "mysql" then
      "${config.services.mysql.package}/bin/mysqldump --single-transaction --routines --triggers -u root ${dbName} > ${file}"
    else
      "${pkgs.util-linux}/bin/runuser -u postgres -- ${config.services.postgresql.package}/bin/pg_dump ${dbName} > ${file}";

  jobOptions = {
    options = {
      paths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Paths to include in the backup.";
      };

      exclude = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Restic exclude patterns.";
      };

      databases = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              driver = lib.mkOption {
                type = lib.types.enum [
                  "mysql"
                  "pgsql"
                ];
                description = "Database server the database lives on.";
              };
              name = lib.mkOption {
                type = lib.types.str;
                description = "Name of the database to dump.";
              };
            };
          }
        );
        default = [ ];
        description = "Local databases to dump and include in the backup.";
      };

      timerConfig = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = cfg.timerConfig;
        description = "systemd timer settings for this job.";
      };

      pruneOpts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = cfg.pruneOpts;
        description = "Arguments to `restic forget --prune` run after each backup.";
      };
    };
  };
in
{
  options.services.ts1997.restic = {
    repositoryBase = lib.mkOption {
      type = lib.types.str;
      example = "s3:https://<account>.r2.cloudflarestorage.com/customer-backups/myhost";
      description = "Each job gets its own restic repository at <repositoryBase>/<job>.";
    };

    passwordFile = lib.mkOption {
      type = lib.types.str;
      description = "Runtime path to the file holding the restic repository password.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.str;
      description = "Runtime path to an env file with the repository credentials (e.g. AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY).";
    };

    timerConfig = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        OnCalendar = "03:30";
        RandomizedDelaySec = "1h";
        Persistent = "true";
      };
      description = "Default systemd timer settings for all jobs.";
    };

    pruneOpts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];
      description = "Default retention for all jobs.";
    };

    jobs = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule jobOptions);
      default = { };
      description = "Restic backup jobs, one repository per attribute name.";
    };
  };

  config = lib.mkIf (cfg.jobs != { }) {
    services.restic.backups = lib.mapAttrs (
      name: job:
      let
        hasDumps = job.databases != [ ];
      in
      {
        repository = "${cfg.repositoryBase}/${name}";
        inherit (cfg) passwordFile environmentFile;
        inherit (job) exclude timerConfig pruneOpts;
        initialize = true;
        paths = job.paths ++ lib.optional hasDumps (dumpDir name);

        backupPrepareCommand = lib.mkIf hasDumps ''
          #!${pkgs.runtimeShell}
          set -euo pipefail
          rm -rf ${dumpDir name}
          install -d -m 0700 ${dumpDir name}
          ${lib.concatMapStringsSep "\n" (dumpCommand name) job.databases}
        '';

        backupCleanupCommand = lib.mkIf hasDumps ''
          #!${pkgs.runtimeShell}
          rm -rf ${dumpDir name}
        '';
      }
    ) cfg.jobs;
  };
}
