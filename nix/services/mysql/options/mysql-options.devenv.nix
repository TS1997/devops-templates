{
  lib,
  pkgs,
  util,
  ...
}:
{
  options = {
    databases = lib.mkOption {
      # Use lib.types.submodule here instead of util.submodule to avoid circular dependency
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            password = lib.mkOption {
              type = lib.types.str;
              default = "1234";
              description = "The password for the database user.";
            };
          };
        }
      );
    };

    phpmyadmin = lib.mkOption {
      type = util.submodule {
        options = {
          enable = lib.mkEnableOption "Enable phpMyAdmin for database management.";

          package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.phpmyadmin;
            description = "The phpMyAdmin package to use.";
          };

          host = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "The host where phpMyAdmin will be hosted.";
          };

          port = lib.mkOption {
            type = lib.types.int;
            default = 8081;
            description = "The port on which phpMyAdmin will be accessible.";
          };
        };
      };
      default = { };
      description = "phpMyAdmin configuration.";
    };
  };

  config = {
    socket = util.values.mysqlSocket;
  };
}
