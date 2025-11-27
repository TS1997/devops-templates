{
  lib,
  pkgs,
  ...
}:
{
  options = {
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The primary domain for the app.";
    };

    extraDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional domains for the app.";
    };

    appName = lib.mkOption {
      type = lib.types.str;
      description = "The name of the application.";
    };

    appEnv = lib.mkOption {
      type = lib.types.enum [
        "production"
        "staging"
        "local"
      ];
      description = "The application environment.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Environment variables to set for the application.";
    };

    locale = lib.mkOption {
      type = lib.types.str;
      default = "en";
      description = "The application locale.";
    };

    workingDir = lib.mkOption {
      type = lib.types.str;
      description = "The working directory for the app.";
    };

    webRoot = lib.mkOption {
      type = lib.types.path;
      description = "The web root directory for the app.";
    };

    php = lib.mkOption {
      type = lib.types.submodule (
        { config, ... }:
        {
          imports = [
            (import ../../modules/phpfpm/phpfpm-options.nix { inherit lib pkgs; })
          ];
        }
      );
      default = { };
      description = "PHP-FPM service configuration for the app.";
    };

    database = {
      enable = lib.mkEnableOption "Enable database configuration for the app.";

      driver = lib.mkOption {
        type = lib.types.enum [
          "mysql"
          "pgsql"
        ];
        default = "mysql";
        description = "The database driver to use.";
      };

      name = lib.mkOption {
        type = lib.types.str;
        description = "The name of the database.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        description = "The database user.";
      };
    };

    redis = {
      enable = lib.mkEnableOption "Enable Redis configuration for the app.";
    };
  };
}
