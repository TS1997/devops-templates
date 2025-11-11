{
  config,
  pkgs,
  lib,
  options,
  ...
}:
let
  cfg = config.services.ts1997.php;

  mkDefaultPoolSettings = import ../settings/phpfpm-pool-settings.nix // {
    "php_admin_value[error_log]" = "/dev/stderr";
  };

  mkDefaultPoolPhpOptions = import ../settings/phpfpm-pool-php-options.nix + ''
    error_log = /dev/stderr
  '';
in
{
  options.services.ts1997.php = options.languages.php;

  config = lib.mkIf (cfg.enable) {
    languages.php = cfg // {
      enable = lib.mkDefault true;
      package = lib.mkDefault cfg.package;

      fpm = {
        pools.web = {
          phpPackage = lib.mkDefault pkgs.php83;

          settings = lib.mkMerge [
            (mkDefaultPoolSettings)
            (cfg.fpm.pools.web.settings or { })
          ];

          phpOptions = mkDefaultPoolPhpOptions + (cfg.fpm.pools.web.phpOptions or "");
        };
      };
    };

    processes = {
      php_error.exec = "touch ${config.env.DEVENV_STATE}/php_error; tail -f ${config.env.DEVENV_STATE}/php_error";
    };
  };
}
