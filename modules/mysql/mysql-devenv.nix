{
  config,
  pkgs,
  lib,
  options,
  ...
}:
let
  cfg = config.services.ts1997.mysql;

  filteredCfg = builtins.removeAttrs cfg [
    "name"
    "user"
    "password"
  ];
in
{
  options.services.ts1997.mysql = options.services.mysql // {
    name = lib.mkOption {
      type = lib.types.str;
      default = "db_name";
      description = "The name of the MySQL database.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "admin";
      description = "The MySQL user for this database.";
    };

    password = lib.mkOption {
      type = lib.types.str;
      default = "1234";
      description = "The password for the MySQL user.";
    };
  };

  config = lib.mkIf (cfg != { }) {
    services.mysql = filteredCfg // {
      enable = true;
      package = pkgs.mariadb;

      initialDatabases = [
        { name = cfg.name; }
      ]
      ++ cfg.initialDatabases;

      ensureUsers = [
        {
          name = cfg.user;
          password = cfg.password;
          ensurePermissions = {
            "*.*" = "ALL PRIVILEGES";
          };
        }
      ]
      ++ cfg.ensureUsers;
    };
  };
}
