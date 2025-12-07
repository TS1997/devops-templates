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
              type = with lib.types; nullOr (functionTo (listOf package));
              default = null;
              example = extensions: [
                extensions.pg_cron
                extensions.postgis
                extensions.timescaledb
              ];
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
