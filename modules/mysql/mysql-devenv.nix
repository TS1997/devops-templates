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
            name = "admin";
            password = "1234";
            ensurePermissions = {
              "*.*" = "ALL PRIVILEGES";
            };
          }
        ];
      };

      ts1997.phpmyadmin = cfg.phpmyadmin;
    };

    scripts = {
      mysql-local.exec = "mysql -u admin -p1234 ${cfg.name} \"$@\"";
    };
  };
}
