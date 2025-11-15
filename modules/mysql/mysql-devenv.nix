{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.ts1997.mysql;
in
{
  options.services.ts1997.mysql = {
    enable = lib.mkEnableOption "Enable MySQL database.";

    name = lib.mkOption {
      type = lib.types.str;
      default = "default_db";
      description = "The name of the MySQL database.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "admin";
      description = "The MySQL database user.";
    };

    password = lib.mkOption {
      type = lib.types.str;
      default = "1234";
      description = "The MySQL database password.";
    };

    phpmyadmin = options.services.ts1997.phpmyadmin;
  };

  config = lib.mkIf cfg.enable {
    services = {
      mysql = {
        enable = cfg.enable;
        package = pkgs.mariadb;

        initialDatabases = [
          { name = cfg.name; }
        ];

        ensureUsers = [
          {
            name = cfg.user;
            password = cfg.password;
            ensurePermissions = {
              "*.*" = "ALL PRIVILEGES";
            };
          }
        ];
      };

      ts1997.phpmyadmin = cfg.phpmyadmin // {
        database = {
          user = cfg.user;
          password = cfg.password;
        };
      };
    };

    scripts = {
      mysql-local.exec = "mysql -u ${cfg.user} -p${cfg.password} ${cfg.name} \"$@\"";
    };
  };
}
