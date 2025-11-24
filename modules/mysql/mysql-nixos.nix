{
  config,
  lib,
  pkgs,
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
      package = pkgs.mysql84;

      initialDatabases = lib.mapAttrsToList (name: _: {
        name = name;
      }) cfg;

      ensureDatabases = lib.mapAttrsToList (name: _: name) cfg;
      ensureUsers = lib.mapAttrsToList (name: dbCfg: {
        name = dbCfg.user;
        ensurePermissions = {
          "${name}.*" = "ALL PRIVILEGES";
        };
      }) cfg;
    };
  };
}
