{
  config,
  pkgs,
  lib,
  options,
  ...
}:
let
  cfg = config.services.ts1997.phpPools;

  mkDefaultPoolSettings =
    poolCfg:
    import ../settings/phpfpm-pool-settings.nix
    // {
      "listen.owner" = "nginx";
      "listen.group" = poolCfg.user;
      "listen.mode" = "0660";
      "php_admin_value[error_log]" = "/var/log/phpfpm-error.log";
    };

  mkDefaultPoolPhpOptions =
    name:
    import ../settings/phpfpm-pool-php-options.nix
    + ''
      error_log = /var/log/${name}/php-error.log
    '';

  mkFilterPoolCfg = poolCfg: builtins.removeAttrs poolCfg [ "socket" ];
in
{
  options.services.ts1997.phpPools = options.services.phpfpm.pools;

  config = lib.mkIf (cfg != { }) {
    services.phpfpm.pools = lib.mapAttrs (
      name: poolCfg:
      (mkFilterPoolCfg poolCfg)
      // {
        group = lib.mkDefault poolCfg.user;
        phpPackage = lib.mkDefault pkgs.php83;

        settings = lib.mkMerge [
          (mkDefaultPoolSettings poolCfg)
          (poolCfg.settings or { })
        ];

        phpOptions = (mkDefaultPoolPhpOptions name) + (poolCfg.phpOptions or "");
      }
    ) cfg;
  };
}
