{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.mysql;
in
{
  options.services.ts1997.mysql = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          user = lib.mkOption {
            type = lib.types.str;
            default = "mysql";
            description = "The system user to run the MySQL instance under.";
          };

          dbName = lib.mkOption {
            type = lib.types.str;
            description = "The name of the MySQL database.";
          };
        };
      }
    );
    default = { };
    description = "List of MySQL databases to enable.";
  };

  config = lib.mkIf (cfg != { }) {
    services.mysql = {
      enable = true;
      package = pkgs.mariadb;

      initialDatabases = lib.mapAttrsToList (name: dbCfg: {
        name = dbCfg.database.name;
      }) cfg;

      ensureDatabases = lib.mapAttrsToList (name: dbCfg: dbCfg.dbName) cfg;

      ensureUsers = lib.mapAttrsToList (name: dbCfg: {
        name = dbCfg.user;
        ensurePermissions = {
          "${dbCfg.dbName}.*" = "ALL PRIVILEGES";
        };
      }) cfg;
    };
  };
}
