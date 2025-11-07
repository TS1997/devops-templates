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
    };

    redis = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable Redis for the site.";
      };
    };
  };
}
