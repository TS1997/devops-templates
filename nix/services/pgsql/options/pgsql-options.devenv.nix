{
  lib,
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
  };

  config = {
    socket = util.values.pgsqlSocket;
  };
}
