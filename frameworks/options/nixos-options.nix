{
  lib,
  pkgs,
  name,
  ...
}:
{
  imports = [
    (import ./shared-options.nix {
      inherit lib pkgs;
    })
  ];

  options = {
    user = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "The system user for the app.";
    };

    forceWWW = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to force www redirection for the application.";
    };
  };

  config = {
    # Shared option defaults
    appEnv = lib.mkDefault "production";
    workingDir = "/var/lib/${name}";
    webRoot = "/var/lib/${name}/public";
    database.enable = lib.mkDefault true;
    database.user = lib.mkDefault name;
  };
}
