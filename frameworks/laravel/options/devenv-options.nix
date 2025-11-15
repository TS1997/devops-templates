{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (import ./shared-options.nix {
      inherit lib pkgs;
    })
  ];

  options = {
    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "The port on which the application will be accessible.";
    };

    sslPort = lib.mkOption {
      type = lib.types.int;
      default = 5443;
      description = "The SSL port on which the application will be accessible.";
    };

    enableSsl = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable SSL for the application.";
    };

    phpmyadmin = {
      enable = lib.mkEnableOption "Enable phpMyAdmin for database management.";

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

  config = {
    # Shared option defaults
    workingDir = lib.mkDefault config.env.DEVENV_ROOT;
    webRoot = lib.mkDefault "${config.env.DEVENV_ROOT}/public";
    database.enable = lib.mkDefault true;
    phpmyadmin.enable = lib.mkDefault true;
  };
}
