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
      imports = [ ./options/mysql-options.base.nix ];
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

      ensureUsers = map (dbCfg: {
        name = dbCfg.user;
        ensurePermissions = {
          "*.*" = "ALL PRIVILEGES";
        };
      }) cfg.databases;
    };

    scripts.mysql-local.exec = ''
      names=(${lib.concatStringsSep " " (map (db: db.name) cfg.databases)})
      users=(${lib.concatStringsSep " " (map (db: db.user) cfg.databases)})

      if [ ${toString (lib.length (cfg.databases))} -gt 1 ]; then
        PS3="Select a database to connect to: "
        select db in "''${names[@]}"; do
          [ -n "$db" ] || continue
          index=$((REPLY-1))
          break
        done
      else
        index=0
        db="''${names[0]}"
      fi

      user="''${users[$index]}"

      mysql -u "$user" "$db" "$@"
    '';
  };
}
