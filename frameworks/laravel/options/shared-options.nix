{ lib, ... }:
{
  options = {
    workingDir = lib.mkOption {
      type = lib.types.str;
      description = "The working directory for the app.";
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
