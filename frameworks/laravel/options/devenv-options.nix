{ config, lib, ... }@args:
{
  imports = [
    (import ./shared-options.nix args)
  ];

  options = {
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
    database.enable = lib.mkDefault true;
    phpmyadmin.enable = lib.mkDefault true;
  };
}
