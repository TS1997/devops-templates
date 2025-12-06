{
  lib,
  pkgs,
  util,
  ...
}:
{
  options = {
    enable = lib.mkEnableOption "Enable PostgreSQL database service.";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.postgresql_18;
      description = "The PostgreSQL package to use.";
    };

    databases = lib.mkOption {
      type = lib.types.listOf (
        util.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "The name of the database.";
            };

            user = lib.mkOption {
              type = lib.types.str;
              description = "The user for the database.";
            };
          };
        }
      );
      default = { };
      description = "Configuration for individual PostgreSQL databases.";
    };
  };
}
