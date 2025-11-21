{
  config,
  lib,
  pkgs,
  name,
  ...
}:
{
  imports = [
    (import ./shared-options.nix {
      inherit config lib pkgs;
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

    database = {
      # Extensions are only used in pgsql
      extensions = lib.mkOption {
        type = with lib.types; coercedTo (listOf path) (path: _ignorePg: path) (functionTo (listOf path));
        default = _: [ ];
        example = lib.literalExpression "ps: with ps; [ postgis pg_repack ]";
        description = ''
          List of PostgreSQL extensions to install.
        '';
      };
    };
  };

  config = {
    # Shared option defaults
    appEnv = lib.mkDefault "production";
    workingDir = lib.mkDefault "/var/lib/${name}";
    webRoot = lib.mkDefault "/var/lib/${name}/public";

    database = {
      enable = lib.mkDefault true;
      user = lib.mkDefault name;
      name = lib.mkDefault name;
    };
  };
}
