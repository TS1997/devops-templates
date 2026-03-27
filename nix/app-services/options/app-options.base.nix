{
  config,
  lib,
  util,
  ...
}:
{
  options = {
    enable = lib.mkEnableOption "Enable Site.";

    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain name of the application.";
    };

    extraDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional domain names for the application.";
    };

    appUrl = lib.mkOption {
      type = lib.types.str;
      description = "The application URL.";
      readOnly = true;
    };

    extraAppUrls = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Additional application URLs.";
      readOnly = true;
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

    appName = lib.mkOption {
      type = lib.types.str;
      description = "The name of the application.";
    };

    appEnv = lib.mkOption {
      type = lib.types.enum [
        "production"
        "staging"
        "development"
        "local"
      ];
      description = "The application environment.";
    };

    env = lib.mkOption {
      type =
        with lib.types;
        attrsOf (
          nullOr (oneOf [
            str
            bool
            int
          ])
        );
      default = { };
      description = "Environment variables for the application.";
    };

    locale = lib.mkOption {
      type = lib.types.str;
      default = "en";
      description = "The application locale.";
    };

    maxExecutionTime = lib.mkOption {
      type = lib.types.int;
      default = 300;
      description = "The maximum execution time for application scripts in seconds.";
    };

    phpPool = lib.mkOption {
      type = util.submodule {
        imports = [ ../../services/phpfpm/options/phpfpm-pool-options.base.nix ];

        config = {
          maxExecutionTime = config.maxExecutionTime;

          extensions =
            extensions:
            [
              extensions.mysqli
              extensions.pdo
              extensions.pdo_mysql
            ]
            ++ lib.optionals config.redis.enable [ extensions.redis ];
        };
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
            default = "pgsql";
            description = "The database driver to use.";
          };

          package = lib.mkOption {
            type = lib.types.package;
            description = "The MySQL package to use.";
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

    redis.enable = lib.mkEnableOption "Enable Redis server for the application.";
  };

  config = {
    database.enable = lib.mkDefault true;
    redis.enable = lib.mkDefault true;
  };
}
