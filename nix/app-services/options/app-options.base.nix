{
  config,
  lib,
  util,
  ...
}:
{
  options = {
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain name of the application.";
    };

    extraDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional domain names for the application.";
    };

    workingDir = lib.mkOption {
      type = lib.types.str;
      description = "The working directory of the application.";
    };

    webRoot = lib.mkOption {
      type = lib.types.str;
      default = "${config.workingDir}/public";
      description = "The web root directory of the application.";
    };

    phpPool = lib.mkOption {
      type = util.submodule {
        imports = [ ../../services/phpfpm/options/phpfpm-pool-options.base.nix ];
      };
      default = { };
      description = "PHP-FPM pool configuration for the application.";
    };

    database = lib.mkOption {
      type = util.submodule {
        options = {
          enable = lib.mkEnableOption "Enable database server for the application.";

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
      };
      default = { };
      description = "Database configuration for the application.";
    };
  };
}
