{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    dumpScript = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = pkgs.writeShellApplication {
        name = "pgsql-database-dump";
        runtimeInputs = [
          config.package
          pkgs.util-linux
        ];
        text = ''
          db="''${1:?Usage: pgsql-database-dump DATABASE [PG_DUMP_ARGS...] > PATH_TO_FILE}"
          shift
          exec runuser -u postgres -- pg_dump "$@" "$db"
        '';
      };
      description = "`pgsql-database-dump DATABASE [PG_DUMP_ARGS...]`: writes an SQL dump of a local database to stdout. Run as root.";
    };

    databases = lib.mkOption {
      # Use lib.types.submodule here instead of util.submodule to avoid circular dependency
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            extensions = lib.mkOption {
              type =
                with lib.types;
                coercedTo
                  (listOf (oneOf [
                    path
                    str
                  ]))
                  (items: _ignorePg: items)
                  (
                    functionTo (
                      listOf (oneOf [
                        path
                        str
                      ])
                    )
                  );
              default = _: [ ];
              example = lib.literalExpression "ps: with ps; [ postgis \"postgis_raster\" pg_repack ]";
              description = "PostgreSQL extensions to enable. Use package paths for installable extensions and strings for SQL extension names already provided by installed packages.";
            };
          };
        }
      );
    };
  };

  config = {
    socket = "/run/postgresql";
  };
}
