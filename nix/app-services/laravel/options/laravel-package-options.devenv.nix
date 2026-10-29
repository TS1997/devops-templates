{
  lib,
  pkgs,
  util,
  ...
}:
{
  options = {
    enable = lib.mkEnableOption "Enable Laravel package development tooling.";

    env = lib.mkOption {
      type =
        with lib.types;
        attrsOf (
          nullOr (oneOf [
            str
            bool
            int
          ])
        );
      default = { };
      description = "Environment variables for Laravel package development.";
    };

    phpPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.php;
      description = "The PHP package to use for package development.";
    };

    nodejs = lib.mkOption {
      type = util.submodule {
        imports = [ ../../../services/nodejs/options/nodejs-options.devenv.nix ];

        config = {
          install.enable = lib.mkDefault true;
          script = lib.mkDefault "npm run dev";
        };
      };
      default = { };
      description = "Node.js development tooling configuration for the package.";
    };

    composer = {
      install.enable = lib.mkEnableOption "Enable automatic Composer installation in development shell.";
      auth.enable = lib.mkEnableOption "Export the shared Composer auth (composer_auth in devops-templates secrets) as COMPOSER_AUTH.";
    };

    generate-types.enable = lib.mkEnableOption "Enable automatic TypeScript type generation.";
  };

  config = {
    composer.install.enable = lib.mkDefault true;
    composer.auth.enable = lib.mkDefault true;
    nodejs.auth.enable = lib.mkDefault true;
  };
}
