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
            name = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "The name of the MySQL database.";
            };

            user = lib.mkOption {
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
        name = dbCfg.name;
      }) cfg;

      ensureDatabases = lib.mapAttrsToList (name: dbCfg: dbCfg.name) cfg;
      ensureUsers = lib.mapAttrsToList (name: dbCfg: {
        name = dbCfg.user;
        ensurePermissions = {
          "${dbCfg.name}.*" = "ALL PRIVILEGES";
        };
      }) cfg;
    };
  };
}
