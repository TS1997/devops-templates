{
  config,
  lib,
  util,
  pkgs,
  ...
}:
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

    nodejs = lib.mkOption {
      type = util.submodule {
        options = {
          enable = lib.mkEnableOption "Enable Node.js development server for the application.";

          install.enable = lib.mkEnableOption "Enable automatic installation of Node.js dependencies.";

          package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.nodejs_24;
            description = "The Node.js package to use for the application.";
          };

          script = lib.mkOption {
            type = lib.types.str;
            default = "npm run dev";
            description = "The npm script to run for the development server.";
          };
        };

        config = {
          enable = lib.mkDefault true;
          install.enable = lib.mkDefault true;
        };
      };
      default = { };
      description = "Node.js configuration for the application.";
    };

    database = lib.mkOption {
      # Use lib.types.submodule here instead of util.submodule to avoid circular dependency
      type = lib.types.submodule {
        options = {
          password = lib.mkOption {
            type = lib.types.str;
            default = "1234";
            description = "The password for the database user.";
          };

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

    mailpit.enable = lib.mkEnableOption "Enable Mailpit service for email testing.";
  };

  config = {
    appUrl =
      if (config.enableSsl) then
        "https://${config.domain}:${toString config.sslPort}"
      else
        "http://${config.domain}:${toString config.port}";

    extraAppUrls = map (
      domain:
      if (config.enableSsl) then
        "https://${domain}:${toString config.sslPort}"
      else
        "http://${domain}:${toString config.port}"
    ) config.extraDomains;

    appEnv = lib.mkDefault "local";

    workingDir = lib.mkDefault util.values.devenvRoot;
    database.user = lib.mkDefault "admin";
    mailpit.enable = lib.mkDefault true;
  };
}
