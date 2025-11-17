{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (import ./shared-options.nix {
      inherit config lib pkgs;
    })
  ];

  options = {
    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "The port on which the application will be accessible.";
    };

    sslPort = lib.mkOption {
      type = lib.types.int;
      default = 5443;
      description = "The SSL port on which the application will be accessible.";
    };

    enableSsl = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable SSL for the application.";
    };

    database = {
      password = lib.mkOption {
        type = lib.types.str;
        default = "1234";
        description = "The database password.";
      };

      # Extensions are only used for pgsql
      extensions = lib.mkOption {
        type = with lib.types; nullOr (functionTo (listOf package));
        default = null;
        example = lib.literalExpression ''
          extensions: [
            extensions.pg_cron
            extensions.postgis
            extensions.timescaledb
          ];
        '';
        description = ''
          Additional PostgreSQL extensions to install.

          The available extensions are:

          ${lib.concatLines (builtins.map (x: "- " + x) (builtins.attrNames pkgs.postgresql.pkgs))}
        '';
      };
    };

    phpmyadmin = {
      enable = lib.mkEnableOption "Enable phpMyAdmin for database management.";

      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "The host where phpMyAdmin will be hosted.";
      };

      port = lib.mkOption {
        type = lib.types.int;
        default = 8081;
        description = "The port on which phpMyAdmin will be accessible.";
      };
    };

    vite = {
      enable = lib.mkEnableOption "Enable Vite development server.";

      nodePackage = lib.mkOption {
        type = lib.types.package;
        default = pkgs.nodejs;
        description = "The Node.js package to use for the Vite development server.";
      };
    };
  };

  config = {
    # Shared option defaults
    appEnv = lib.mkDefault "local";
    workingDir = lib.mkDefault config.env.DEVENV_ROOT;
    webRoot = lib.mkDefault "${config.env.DEVENV_ROOT}/public";

    database = {
      enable = lib.mkDefault true;
      user = lib.mkDefault "admin";
    };

    phpmyadmin = {
      enable = lib.mkDefault true;
    };
  };
}
