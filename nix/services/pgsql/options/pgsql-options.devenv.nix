{
  lib,
  pkgs,
  util,
  ...
}:
{
  options = {
    databases = lib.mkOption {
      # Use lib.types.submodule here instead of util.submodule to avoid circular dependency
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            password = lib.mkOption {
              type = lib.types.str;
              default = "1234";
              description = "The password for the database user.";
            };

            extensions = lib.mkOption {
              type =
                with lib.types;
                nullOr (
                  functionTo (
                    listOf (oneOf [
                      package
                      str
                    ])
                  )
                );
              default = null;
              example = extensions: [
                extensions.pg_cron
                extensions.postgis
                "postgis_raster"
                extensions.timescaledb
              ];
              description = "PostgreSQL extensions to enable. Use packages for installable extensions and strings for SQL extension names already provided by installed packages.";
            };
          };
        }
      );
    };

    pgAdmin = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "Whether to set up pgAdmin for this PostgreSQL instance.";

          package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.pgadmin4-desktopmode;
            description = "The pgAdmin package to use.";
          };

          host = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "The pgAdmin server host.";
          };

          port = lib.mkOption {
            type = lib.types.int;
            default = 5050;
            description = "The pgAdmin server port.";
          };
        };
      };
      default = { };
    };
  };

  config = {
    socket = util.values.pgsqlSocket;
  };
}
