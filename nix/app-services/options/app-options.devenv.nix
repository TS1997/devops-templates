{
  config,
  lib,
  util,
  pkgs,
  ...
}:
let
  inherit (lib) types mkOption mkEnableOption;
in
{
  options = {
    port = mkOption {
      type = types.int;
      default = 8080;
      description = "The port that the application will be served on.";
    };

    sslPort = mkOption {
      type = types.int;
      default = 5443;
      description = "The SSL port that the application will be served on.";
    };

    enableSsl = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable SSL for the application.";
    };

    composer.install.enable = mkEnableOption "Enable automatic Composer installation in development shell.";

    nodejs = mkOption {
      type = util.submodule {
        options = {
          enable = mkEnableOption "Enable Node.js development server for the application.";

          install.enable = mkEnableOption "Enable automatic installation of Node.js dependencies.";

          package = mkOption {
            type = types.package;
            default = pkgs.nodejs_24;
            description = "The Node.js package to use for the application.";
          };

          script = mkOption {
            type = types.nullOr types.str;
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

    database = mkOption {
      # Use types.submodule here instead of util.submodule to avoid circular dependency
      type = types.submodule {
        options = {
          password = mkOption {
            type = types.str;
            default = "1234";
            description = "The password for the database user.";
          };

          admin.enable = mkEnableOption "Enable database admin user interface for the application.";

          # Database extensions to be installed if using PostgreSQL
          extensions = mkOption {
            type =
              with types;
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

        config = {
          admin.enable = lib.mkDefault true;
        };
      };
    };

    mailpit.enable = mkEnableOption "Enable Mailpit service for email testing.";
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
    composer.install.enable = lib.mkDefault true;
    workingDir = lib.mkDefault util.values.devenvRoot;
    database.user = lib.mkDefault "admin";
    mailpit.enable = lib.mkDefault true;
  };
}
