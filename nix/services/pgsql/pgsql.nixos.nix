{
  config,
  lib,
  pkgs,
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
        ./options/pgsql-options.nixos.nix
      ];
    };
    default = { };
    description = "PostgreSQL service configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    services.postgresql = {
      enable = cfg.enable;
      package = cfg.package;
      extensions = _: allExtensionPackages;

      ensureDatabases = map (dbCfg: dbCfg.name) cfg.databases;

      ensureUsers = map (dbCfg: {
        name = dbCfg.user;
        ensureDBOwnership = true;
      }) cfg.databases;

      settings.port = cfg.port;

      authentication = lib.mkAfter ''
        # type database user auth-method
        ${lib.concatMapStringsSep "\n" (dbCfg: ''
          local ${dbCfg.name} ${dbCfg.user} peer
          local ${dbCfg.name} postgres peer
        '') cfg.databases}
      '';
    };

    systemd.services.create-pgsql-extensions = {
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ cfg.package ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        ExecStart = pkgs.writeShellScript "create-pgsql-extensions" ''
          set -e
          ${lib.concatMapStringsSep "\n" (
            dbCfg:
            lib.optionalString (dbCfg.extensions != null) (
              lib.concatMapStringsSep "\n" (extPkg: ''
                psql -d ${dbCfg.name} -c "CREATE EXTENSION IF NOT EXISTS \"${extPkg.name}\";"
              '') (normalizeExtensions dbCfg)
            )
          ) cfg.databases}
        '';
      };
    };
  };
}
