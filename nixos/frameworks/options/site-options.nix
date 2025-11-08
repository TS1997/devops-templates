{
  config,
  pkgs,
  lib,
  name,
  ...
}:
{
  options = {
    user = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "The default system user.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      description = "The default domain name.";
    };

    forceWWW = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to force www redirection.";
    };

    appName = lib.mkOption {
      type = lib.types.str;
      default = "Laravel Application";
      description = "The name of the Laravel application.";
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
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Additional environment variables for the application.";
    };

    environmentSecretsPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to agenix secrets file containing environment variables for this site as JSON";
    };

    workingDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${name}";
      description = "The default working directory.";
    };

    webRoot = lib.mkOption {
      type = lib.types.str;
      default = "${config.workingDir}/public";
      description = "The default web root directory.";
    };

    phpPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.php83;
      description = "The default PHP package to use.";
    };

    postDeployCommands = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of shell commands to run after deploying the application.";
    };

    database = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable a database for the site.";
      };

      connection = lib.mkOption {
        type = lib.types.enum [
          "mysql"
          "pgsql"
        ];
        default = "mysql";
        description = "The type of database connection.";
      };

      socket = lib.mkOption {
        type = lib.types.str;
        default = "/run/mysqld/mysqld.sock";
        description = "The database socket path (if applicable).";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = config.user;
        description = "The database user for the site.";
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = config.user;
        description = "The database name for the site.";
      };
    };

    redis = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable Redis for the site.";
      };

      socket = lib.mkOption {
        type = lib.types.str;
        default = "/run/redis-${config.user}/redis.sock";
        description = "The Redis socket path.";
      };
    };
  };
}
