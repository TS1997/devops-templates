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

  # Only because devenv has problems with the task system. This is not necessary otherwise.
  initSql = pkgs.writeText "mysql-init.sql" (
    lib.concatMapStrings (dbCfg: ''
      CREATE DATABASE IF NOT EXISTS `${dbCfg.name}`;
      CREATE USER IF NOT EXISTS '${dbCfg.user}'@'localhost' IDENTIFIED BY '${dbCfg.password}';
      GRANT ALL PRIVILEGES ON *.* TO '${dbCfg.user}'@'localhost';
      FLUSH PRIVILEGES;
    '') cfg.databases
  );

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

      settings = {
        mysqld = {
          log_bin_trust_function_creators = 1;
        };
      };

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
      phpmyadmin = lib.mkIf (phpMyAdminCfg.enable) {
        exec = ''
          php -S ${phpMyAdminCfg.host}:${toString phpMyAdminCfg.port} -t ${phpmyadmin}
        '';
        ready = {
          http.get = {
            host = phpMyAdminCfg.host;
            port = phpMyAdminCfg.port;
            path = "/";
          };
          initial_delay = 2;
          period = 1;
          probe_timeout = 5;
          success_threshold = 1;
          failure_threshold = 30;
        };
      };
    };

    scripts = {
      phpmyadmin.exec = "xdg-open http://${phpMyAdminCfg.host}:${toString phpMyAdminCfg.port}/ || open http://${phpMyAdminCfg.host}:${toString phpMyAdminCfg.port}/";

      # Only added because task system is fucked as of 2026-05-20. Remove asap.
      init-database.exec = ''
        mysql -u root < ${initSql}
      '';

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
