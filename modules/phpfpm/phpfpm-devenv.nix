{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.php;

  defaultPoolSettings = import ./settings/pool-settings.nix // {
    "php_admin_value[error_log]" = "/dev/stderr";
  };

  defaultPhpOptions = import ./settings/php-options.nix + ''
    error_log = /dev/stderr
  '';
in
{
  options.services.ts1997.php = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable PHP-FPM for the development environment.";
    };

    phpPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.php;
      description = "The PHP package to use for the PHP-FPM service.";
    };
  };

  config = lib.mkIf (cfg.enable) {
    languages.php = {
      enable = true;
      package = cfg.phpPackage;

      fpm.pools.web = {
        phpPackage = cfg.phpPackage;
        settings = defaultPoolSettings;
        phpOptions = defaultPhpOptions;
      };
    };

    processes = {
      php_error.exec = "touch ${config.env.DEVENV_STATE}/php_error; tail -f ${config.env.DEVENV_STATE}/php_error";
    };

    packages = [ cfg.phpPackage ];
  };
}
