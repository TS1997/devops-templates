{
  config,
  lib,
  util,
  ...
}:
let
  cfg = config.services.ts1997.pgsql;

  extensionName = dbPkg: dbPkg.pname or dbPkg.name or "unknown_extension";

  normalizeExtensions =
    dbCfg:
    map (
      extension:
      if builtins.isString extension then
        {
          name = extension;
          package = null;
        }
      else
        {
          name = extensionName extension;
          package = extension;
        }
    ) (if dbCfg.extensions != null then dbCfg.extensions cfg.package.pkgs else [ ]);

  allExtensionPackages = lib.unique (
    lib.flatten (
      map (
        dbCfg: map (ext: ext.package) (lib.filter (ext: ext.package != null) (normalizeExtensions dbCfg))
      ) cfg.databases
    )
  );
in
{
  options.services.ts1997.pgsql = lib.mkOption {
    type = util.submodule {
      imports = [
        ./options/pgsql-options.base.nix
        ./options/pgsql-options.devenv.nix
      ];
    };
    default = { };
    description = "PostgreSQL service configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    services.postgres = {
      enable = cfg.enable;
      package = cfg.package;
      extensions = _: allExtensionPackages;
      settings.port = cfg.port;

      initialDatabases = map (dbCfg: {
        name = dbCfg.name;
        user = dbCfg.user;
        pass = dbCfg.password;
      }) cfg.databases;

      initialScript = ''
        ${lib.concatMapStringsSep "\n" (dbCfg: ''
          \c ${dbCfg.name}
          ${lib.optionalString (dbCfg.extensions != null) (
            lib.concatMapStringsSep "\n" (ext: "CREATE EXTENSION IF NOT EXISTS \"${ext.name}\";") (
              normalizeExtensions dbCfg
            )
          )}
        '') cfg.databases}
      '';
    };

    scripts = {
      psql-local.exec = ''
        names=(${lib.concatStringsSep " " (map (db: db.name) cfg.databases)})
        users=(${lib.concatStringsSep " " (map (db: db.user) cfg.databases)})

        source ${../../utils/select-database.sh}

        psql -U "$user" "$db" "$@"
      '';
    };
  };
}
