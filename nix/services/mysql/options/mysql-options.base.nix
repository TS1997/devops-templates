{
  lib,
  pkgs,
  util,
  ...
}:
{
  options = {
    enable = lib.mkEnableOption "Enable MySQL database service.";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.mysql84;
      description = "The MySQL package to use.";
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
      description = "Configuration for individual MySQL databases.";
    };
  };
}
