{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.pgsql;

  mkAuthRules = lib.concatMapStringsSep "\n" (
    name: dbCfg: "local ${dbCfg.dbName} ${dbCfg.dbUser} peer"
  ) (lib.mapAttrsToList (name: dbCfg: dbCfg) cfg);
in
{
  options.services.ts1997.pgsql = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            dbName = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "The name of the PostgreSQL database.";
            };

            dbUser = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "The PostgreSQL user for this database.";
            };
          };
        }
      )
    );
    default = { };
    description = "List of PostgreSQL databases to enable.";
  };

  config = lib.mkIf (cfg != { }) {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql;

      ensureDatabases = lib.mapAttrsToList (name: dbCfg: dbCfg.dbName) cfg;

      ensureUsers = lib.mapAttrsToList (name: dbCfg: {
        name = dbCfg.dbUser;
        ensureDBOwnership = true;
      }) cfg;

      authentication = lib.mkOverride 10 ''
        #type database DBuser auth-method
        ${mkAuthRules}
        local all all reject
      '';
    };
  };
}
