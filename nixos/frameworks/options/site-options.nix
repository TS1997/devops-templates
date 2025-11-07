{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "nginx";
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

    workingDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${config.user}";
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

    mail = {
      mailer = lib.mkOption {
        type = lib.types.str;
        default = "smtp";
        description = "The mailer to use for sending emails.";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "The SMTP host.";
      };

      port = lib.mkOption {
        type = lib.types.int;
        default = 587;
        description = "The SMTP port.";
      };

      username = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The SMTP username.";
      };

      password = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The SMTP password.";
      };

      from = {
        address = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "The default 'from' email address.";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = config.appName;
          description = "The default 'from' name.";
        };
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

    timezone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Stockholm";
      description = "The default timezone for the application.";
    };

    locale = lib.mkOption {
      type = lib.types.str;
      default = "en";
      description = "The default locale for the application.";
    };
  };
}
