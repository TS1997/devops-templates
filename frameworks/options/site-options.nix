{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    # Shared options
    phpPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.php;
      description = "The PHP package to use for this site.";
    };

    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        The primary domain name for this site.
      '';
      example = "example.org";
    };

    extraDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "www.example.org"
        "example.org"
      ];
      description = ''
        Additional domain names for this site.
      '';
    };

    workingDir = lib.mkOption {
      type = lib.types.path;
      description = "The working directory for the site.";
    };

    webRoot = lib.mkOption {
      type = lib.types.path;
      default = "${config.workingDir}/public";
      description = ''
        The web root directory for the site. Defaults to
        "<workingDir>/public".
      '';
    };

    database = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to create a MySQL database for this site.";
      };

      connection = lib.mkOption {
        type = lib.types.enum [
          "mysql"
          "pgsql"
        ];
        default = "mysql";
        description = "The type of database connection.";
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = "db_name";
        description = "The name of the MySQL database for this site.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "admin";
        description = "The MySQL user for this site's database.";
      };

      # Devenv-specific database option
      password = lib.mkOption {
        type = lib.types.str;
        default = "1234";
        description = "The password for the MySQL user.";
      };
    };

    # NixOS-specific options
    user = lib.mkOption {
      type = lib.types.str;
      default = "nginx";
      description = "The user that the PHP-FPM pool will run as.";
    };

    forceWWW = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to force www redirection for this site.";
    };

    # Devenv-specific options
    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "The port that nginx will listen on.";
    };

    sslPort = lib.mkOption {
      type = lib.types.int;
      default = 5443;
      description = "The port that nginx will listen on for SSL.";
    };

    enableSsl = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable SSL for the nginx virtual host.";
    };
  };
}
