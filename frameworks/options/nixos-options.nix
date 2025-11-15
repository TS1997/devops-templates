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

    environmentSecretsPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a file containing environment variable secrets.";
    };

    postDeployCommands = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of commands to run after deployment.";
    };
  };

  config = {
    # Shared option defaults
    appEnv = lib.mkDefault "production";
    workingDir = "/var/lib/${name}";
    webRoot = "/var/lib/${name}/public";

    database = {
      enable = lib.mkDefault true;
      user = lib.mkDefault name;
      name = lib.mkDefault name;
    };
  };
}
