{
  config,
  lib,
  util,
  ...
}:
{
  options = {
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain name of the application.";
    };

    extraDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional domain names for the application.";
    };

    workingDir = lib.mkOption {
      type = lib.types.str;
      description = "The working directory of the application.";
    };

    webRoot = lib.mkOption {
      type = lib.types.str;
      default = "${config.workingDir}/public";
      description = "The web root directory of the application.";
    };

    php = lib.mkOption {
      type = util.submodule {
        imports = [ ../../services/phpfpm/options/phpfpm-pool-options.base.nix ];
      };
      default = { };
      description = "PHP-FPM pool configuration for the application.";
    };
  };
}
