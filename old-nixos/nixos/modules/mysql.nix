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
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            dbName = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "The name of the MySQL database.";
            };

            dbUser = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "The MySQL user for this database.";
            };
          };
        }
      )
    );
    default = { };
    description = "List of MySQL databases to enable.";
  };

  config = lib.mkIf (cfg != { }) {
    services.mysql = {
      enable = true;
      package = pkgs.mariadb;

      initialDatabases = lib.mapAttrsToList (name: dbCfg: {
        name = dbCfg.dbName;
      }) cfg;

      ensureDatabases = lib.mapAttrsToList (name: dbCfg: dbCfg.dbName) cfg;

      ensureUsers = lib.mapAttrsToList (name: dbCfg: {
        name = dbCfg.dbUser;
        ensurePermissions = {
          "${dbCfg.dbName}.*" = "ALL PRIVILEGES";
        };
      }) cfg;
    };
  };
}
