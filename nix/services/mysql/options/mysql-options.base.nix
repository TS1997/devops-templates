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

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "The host address for MySQL.";
      readOnly = true;
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 3306;
      description = "The port for MySQL.";
      readOnly = true;
    };

    socket = lib.mkOption {
      type = lib.types.path;
      description = "The socket path for MySQL.";
      readOnly = true;
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
