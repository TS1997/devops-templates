{
  config,
  lib,
  pkgs,
  util,
  ...
}:
let
  packageCfg = config.services.ts1997.laravelPackage;

  packageScript = pkgs.writeShellApplication {
    name = "laravel-package";
    runtimeInputs = [ packageCfg.phpPackage ];
    text = ''
      php ${./scripts/package-make.php} "$@"
    '';
  };

  initComposerScript = pkgs.writeShellScript "init-laravel-package-composer.sh" ''
    LOCK_HASH_FILE=${util.values.devenvDotfile}/laravel-package-composer.lockhash

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
  options.services.ts1997.laravelPackage = lib.mkOption {
    type = util.submodule {
      imports = [ ./options/laravel-package-options.devenv.nix ];
    };
    default = { };
    description = "Laravel package development configuration.";
  };

  config = lib.mkIf packageCfg.enable {
    env = packageCfg.env;

    languages.php = {
      enable = true;
      package = packageCfg.phpPackage;
    };

    services.ts1997.nodejs = packageCfg.nodejs;

    enterShell = lib.optionalString packageCfg.composer.install.enable ''
      source ${initComposerScript}
    '';

    scripts = {
      package.exec = ''
        ${packageScript}/bin/laravel-package "$@"
      '';

      run-tests.exec = ''
        composer test "$@"
      '';

      format.exec = ''
        composer format "$@"
      '';
    };

    processes = {
      generate-types.exec = lib.mkIf packageCfg.generate-types.enable ''
        php artisan package-types:generate --watch
      '';
    };
  };
}
