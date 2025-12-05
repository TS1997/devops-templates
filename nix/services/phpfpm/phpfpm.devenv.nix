{
  config,
  lib,
  util,
  ...
}:
let
  cfg = config.services.ts1997.phpfpm;

  errorLog = config.languages.php.fpm.settings.error_log;
in
{
  options.services.ts1997.phpfpm = lib.mkOption {
    type = util.submodule {
      imports = [ ./options/phpfpm-options.base.nix ];
    };
    description = "PHP-FPM configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    languages.php = {
      enable = cfg.enable;
      package = cfg.fullPackage;

      fpm = {
        extraConfig = cfg.extraConfig;
        pools = lib.mapAttrs (poolName: poolCfg: {
          extraConfig = poolCfg.extraConfig;
          phpEnv = poolCfg.phpEnv;
          phpOptions = poolCfg.phpOptions;
          phpPackage = poolCfg.fullPackage;
          settings = poolCfg.settings;
        }) cfg.pools;
      };
    };

    processes = {
      php_error.exec = ''
        mkdir -p $(dirname ${errorLog})
        touch ${errorLog}
        tail -f ${errorLog}
      '';
    };
  };
}
