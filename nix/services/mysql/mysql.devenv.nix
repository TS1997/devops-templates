{
  config,
  lib,
  pkgs,
  util,
  ...
}:
let
  cfg = config.services.ts1997.mysql;

  phpmyadmin = (
    import ./submodules/phpmyadmin.nix {
      inherit pkgs util;
      dbCfg = lib.head cfg.databases;
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
        ++ lib.optionals (cfg.phpmyadmin.enable) [
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

    processes.phpmyadmin.exec = lib.mkIf (cfg.phpmyadmin.enable) ''
      php -S ${cfg.phpmyadmin.host}:${toString cfg.phpmyadmin.port} -t ${phpmyadmin}
    '';

    scripts = {
      phpmyadmin.exec = "open http://${cfg.phpmyadmin.host}:${toString cfg.phpmyadmin.port}/";

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
