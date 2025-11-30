{
  lib,
  pkgs,
  siteName,
  ...
}:
{
  domain = lib.mkOption {
    type = lib.types.str;
    description = "The primary domain for the site.";
  };

  extraDomains = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Additional domains for the site.";
  };

  appName = lib.mkOption {
    type = lib.types.str;
    description = "Application name.";
  };

  appEnv = lib.mkOption {
    type = lib.types.enum [
      "production"
      "staging"
      "local"
    ];
    default = "production";
    description = "The application environment.";
  };

  environment = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = { };
    description = "Environment variables to set for the site.";
  };

  locale = lib.mkOption {
    type = lib.types.str;
    default = "en";
    description = "The site locale.";
  };

  workingDir = lib.mkOption {
    type = lib.types.str;
    default = "/var/lib/${siteName}";
    description = "The working directory for the site.";
  };

  webRoot = lib.mkOption {
    type = lib.types.path;
    default = "/var/lib/${siteName}/public";
    description = "The web root directory for the site.";
  };

  php = lib.mkOption {
    type = lib.types.submodule (
      { config, ... }:
      {
        imports = [
          (import ../modules/phpfpm/phpfpm-options.nix { inherit config lib pkgs; })
        ];
      }
    );
    default = { };
    description = "PHP-FPM configuration for the site.";
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
      default = siteName;
      description = "The name of the database.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = siteName;
      description = "The database user.";
    };
  };

  # NixOS Options
  user = lib.mkOption {
    type = lib.types.str;
    default = siteName;
    description = "The system user to run the site.";
  };

  forceWWW = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether to force WWW in the domain.";
  };
}
