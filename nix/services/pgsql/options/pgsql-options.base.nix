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

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "The host address for PostgreSQL.";
      readOnly = true;
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 5432;
      description = "The port for PostgreSQL.";
    };

    socket = lib.mkOption {
      type = lib.types.str;
      description = "The socket path for PostgreSQL.";
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
      description = "Configuration for individual PostgreSQL databases.";
    };
  };
}
