{
  config,
  lib,
  util,
  ...
}:
let
  siteCfg = config.services.ts1997.symfonySite;
in
{
  options.services.ts1997.symfonySite = lib.mkOption {
    type = util.submodule {
      imports = [ ../options/app-hosts.devenv.nix ];

      options = {
        enable = lib.mkEnableOption "a Symfony application deployed with symfony-deploy.yml";

        php = lib.mkOption {
          type = util.submodule {
            imports = [ ../../services/phpfpm/options/phpfpm-package-options.base.nix ];
          };
          default = { };
          description = "PHP package and extensions, used locally and in CI.";
        };

        composer = {
          install.enable = lib.mkEnableOption "automatic Composer installation in the development shell" // {
            default = true;
          };
          auth.enable = lib.mkEnableOption "the shared Composer auth (composer_auth in devops-templates secrets) as COMPOSER_AUTH";
        };

        nodejs = lib.mkOption {
          type = util.submodule {
            imports = [ ../../services/nodejs/options/nodejs-options.devenv.nix ];
          };
          default = { };
          description = "Node.js for apps that build assets with npm (symfony-deploy.yml `build_assets`).";
        };
      };
    };
    default = { };
    description = "Symfony application configuration.";
  };

  config = lib.mkIf siteCfg.enable {
    services.ts1997.phpfpm = {
      enable = true;
      inherit (siteCfg.php) basePackage extensions ini;
      composer.install.enable = siteCfg.composer.install.enable;
    };

    services.ts1997.tokens.variables = lib.mkIf siteCfg.composer.auth.enable [
      "composer_auth:COMPOSER_AUTH"
    ];

    services.ts1997.nodejs = siteCfg.nodejs;

    processes = lib.mkIf (siteCfg.nodejs.enable && siteCfg.nodejs.script != null) {
      nodejs.exec = siteCfg.nodejs.script;
    };
  };
}
