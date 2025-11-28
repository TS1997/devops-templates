{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.php;

  defaultPoolSettings = import ./config/pool-settings.nix // {
    "php_admin_value[error_log]" = "/dev/stderr";
  };

  defaultPhpOptions = import ./config/php-options.nix + ''
    error_log = /dev/stderr
  '';
in
{
  options.services.ts1997.php = lib.mkOption {
    type = lib.types.submodule (
      { config, ... }:
      {
        imports = [
          (import ./phpfpm-options.nix { inherit config lib pkgs; })
        ];
      }
    );
    description = "PHP-FPM service configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    languages.php = {
      enable = cfg.enable;
      package = cfg.packageWithExtensions;

      fpm.pools.web = {
        settings = defaultPoolSettings // cfg.settings;
        phpOptions = defaultPhpOptions + cfg.phpOptions;
      };
    };

    processes = {
      php_error.exec = "touch ${config.env.DEVENV_STATE}/php_error; tail -f ${config.env.DEVENV_STATE}/php_error";
    };
  };
}
