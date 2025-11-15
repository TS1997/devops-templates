{
  config,
  lib,
  options,
  ...
}:
let
  cfg = config.services.ts1997.phpPools;

  defaultPoolSettings =
    poolCfg:
    import ./config/pool-settings.nix
    // {
      "listen.owner" = "nginx";
      "listen.group" = poolCfg.user;
      "listen.mode" = "0660";
      "php_admin_value[error_log]" = "/var/log/phpfpm-error.log";
    };

  defaultPhpOptions =
    name:
    import ./config/php-options.nix
    + ''
      error_log = /var/log/${name}/php-error.log
    '';

  filteredPoolCfg = poolCfg: builtins.removeAttrs poolCfg [ "socket" ];
in
{
  options.services.ts1997.phpPools = options.services.phpfpm.pools;

  config = lib.mkIf (cfg != { }) {
    users.users = lib.mkMerge (
      lib.mapAttrsToList (name: poolCfg: {
        ${poolCfg.user}.packages = [ poolCfg.phpPackage ];
      }) cfg
    );

    services.phpfpm.pools = lib.mapAttrs (
      name: poolCfg:
      (filteredPoolCfg poolCfg)
      // {
        group = lib.mkDefault poolCfg.user;

        settings = lib.mkMerge [
          (defaultPoolSettings poolCfg)
          (poolCfg.settings)
        ];

        phpOptions = (defaultPhpOptions name) + (poolCfg.phpOptions);
      }
    ) cfg;
  };
}
