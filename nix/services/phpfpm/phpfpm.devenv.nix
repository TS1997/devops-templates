{
  config,
  lib,
  pkgs,
  util,
  ...
}:
let
  cfg = config.services.ts1997.phpfpm;

  errorLog = config.languages.php.fpm.settings.error_log;

  initComposerScript = pkgs.writeShellScript "init-composer.sh" ''
    LOCK_HASH_FILE=${util.values.devenvDotfile}/composer.lockhash

    if [ -f composer.lock ]; then
      CURRENT_HASH=$(sha256sum composer.lock | cut -d' ' -f1)
      STORED_HASH=$(cat "$LOCK_HASH_FILE" 2>/dev/null || true)

      if [ "$CURRENT_HASH" != "$STORED_HASH" ]; then
        composer install \
          --no-interaction \
          --prefer-dist \
          --no-progress

        echo "$CURRENT_HASH" > "$LOCK_HASH_FILE"
      fi
    fi
  '';
in
{
  options.services.ts1997.phpfpm = lib.mkOption {
    type = util.submodule {
      imports = [
        ./options/phpfpm-options.base.nix
        ./options/phpfpm-options.devenv.nix
      ];
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

    enterShell = lib.mkIf cfg.composer.install.enable ''
      source ${initComposerScript}
    '';

    processes = {
      php_error.exec = ''
        mkdir -p $(dirname ${errorLog})
        touch ${errorLog}
        tail -f ${errorLog}
      '';
    };
  };
}
