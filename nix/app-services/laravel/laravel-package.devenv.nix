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
            imports = [ ../../services/nodejs/options/nodejs-options.devenv.nix ];

            config = {
              enable = lib.mkDefault true;
              install.enable = lib.mkDefault true;
            };
          };
          default = { };
          description = "Node.js development tooling configuration for the package.";
        };

        composer.install.enable = lib.mkEnableOption "Enable automatic Composer installation in development shell.";
      };

      config = {
        composer.install.enable = lib.mkDefault true;
      };
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
  };
}
