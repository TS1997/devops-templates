{
  config,
  lib,
  util,
  ...
}:
let
  cfg = config.services.ts1997.mysql;
in
{
  options.services.ts1997.mysql = lib.mkOption {
    type = util.submodule {
      imports = [
        ./options/mysql-options.base.nix
        ./options/mysql-options.nixos.nix
      ];
    };
    default = { };
    description = "MySQL service configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    services.mysql = {
      enable = cfg.enable;
      package = cfg.package;

      initialDatabases = map (dbCfg: {
        name = dbCfg.name;
      }) cfg.databases;

      ensureDatabases = map (dbCfg: dbCfg.name) cfg.databases;

      ensureUsers = map (dbCfg: {
        name = dbCfg.user;
        ensurePermissions = {
          "${dbCfg.name}.*" = "ALL PRIVILEGES";
        };
      }) cfg.databases;
    };
  };
}
