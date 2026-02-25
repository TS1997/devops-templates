{
  config,
  lib,
  pkgs,
  util,
  ...
}:
let
  cfg = config.services.ts1997.mysql;
  phpMyAdminCfg = cfg.phpMyAdmin;

  phpmyadmin = (
    import ./submodules/phpmyadmin.nix {
      inherit pkgs util;
      dbCfg = lib.head cfg.databases;
      host = phpMyAdminCfg.host;
      port = phpMyAdminCfg.port;
    }
  );
in
{
  options.services.ts1997.mysql = lib.mkOption {
    type = util.submodule {
      imports = [
        ./options/mysql-options.base.nix
        ./options/mysql-options.devenv.nix
      ];
    };
    default = { };
    description = "MySQL service configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    services.mysql = {
      enable = cfg.enable;
      package = cfg.package;

      initialDatabases =
        map (dbCfg: {
          name = dbCfg.name;
        }) cfg.databases
        ++ lib.optionals (phpMyAdminCfg.enable) [
          {
            name = "phpmyadmin";
            schema = "${phpmyadmin}/sql/create_tables.sql";
          }
        ];

      ensureUsers = map (dbCfg: {
        name = dbCfg.user;
        password = dbCfg.password;
        ensurePermissions = {
          "*.*" = "ALL PRIVILEGES";
        };
      }) cfg.databases;
    };

    processes = {
      mysql = {
        process-compose.readiness_probe = {
          exec.command = "${cfg.package}/bin/mysqladmin ping --socket=${cfg.socket}";
          initial_delay_seconds = 1;
          period_seconds = 1;
          timeout_seconds = 5;
          success_threshold = 1;
          failure_threshold = 30;
        };
      };

      phpmyadmin = lib.mkIf (phpMyAdminCfg.enable) {
        exec = ''
          php -S ${phpMyAdminCfg.host}:${toString phpMyAdminCfg.port} -t ${phpmyadmin}
        '';
        process-compose.readiness_probe = {
          http_get = {
            host = phpMyAdminCfg.host;
            port = phpMyAdminCfg.port;
            path = "/";
          };
          initial_delay_seconds = 2;
          period_seconds = 1;
          timeout_seconds = 5;
          success_threshold = 1;
          failure_threshold = 30;
        };
      };
    };

    scripts = {
      phpmyadmin.exec = "xdg-open http://${phpMyAdminCfg.host}:${toString phpMyAdminCfg.port}/ || open http://${phpMyAdminCfg.host}:${toString phpMyAdminCfg.port}/";

      mysql-local.exec = ''
        names=(${lib.concatStringsSep " " (map (db: db.name) cfg.databases)})
        users=(${lib.concatStringsSep " " (map (db: db.user) cfg.databases)})
        passwords=(${lib.concatStringsSep " " (map (db: db.password) cfg.databases)})

        source ${../../utils/select-database.sh}

        mysql -u "$user" -p"$password" "$db" "$@"
      '';
    };
  };
}
