{ lib, util, ... }:
{
  options = {
    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "The port that the application will be served on.";
    };

    sslPort = lib.mkOption {
      type = lib.types.int;
      default = 5443;
      description = "The SSL port that the application will be served on.";
    };

    enableSsl = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable SSL for the application.";
    };

    database = lib.mkOption {
      # Use lib.types.submodule here instead of util.submodule to avoid circular dependency
      type = lib.types.submodule {
        options = {
          admin.enable = lib.mkEnableOption "Enable database admin user interface for the application.";

          # Database extensions to be installed if using PostgreSQL
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

        config = {
          admin.enable = lib.mkDefault true;
        };
      };
    };
  };

  config = {
    workingDir = lib.mkDefault util.values.devenvRoot;
    database.user = lib.mkDefault "admin";
  };
}
