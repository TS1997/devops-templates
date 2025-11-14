{
  lib,
  name,
  ...
}@args:
{
  imports = [
    (import ./shared-options.nix args)
  ];

  options = {
    user = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "The system user for the app.";
    };

    database.user = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "The database user for the app.";
    };
  };

  config = {
    # Shared option defaults
    workingDir = "/var/lib/${name}";
    database.enable = lib.mkDefault true;
  };
}
