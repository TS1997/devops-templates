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

    workingDir = lib.mkOption {
      type = lib.types.str;
      description = "The working directory for the app.";
    };

    webRoot = lib.mkOption {
      type = lib.types.path;
      description = "The web root directory for the app.";
    };

    phpPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.php;
      description = "The PHP package to use for the app.";
    };

    database = {
      enable = lib.mkEnableOption "Enable database configuration for the app.";

      driver = lib.mkOption {
        type = lib.types.enum [ "mysql" ];
        default = "mysql";
        description = "The database driver to use.";
      };

      name = lib.mkOption {
        type = lib.types.str;
        description = "The name of the database.";
      };
    };
  };
}
