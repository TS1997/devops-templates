{
  config,
  lib,
  pkgs,
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
in
{
  options.services.ts1997.phpPools = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, config, ... }:
        {
          imports = [
            (import ./phpfpm-options.nix { inherit config lib pkgs; })
          ];

          options = {
            user = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "The system user that owns the PHP-FPM pool.";
            };
          };
        }
      )
    );
    description = "PHP-FPM pools configuration.";
  };

  config = lib.mkIf (cfg != { }) {
    users.users = lib.mkMerge (
      lib.mapAttrsToList (name: poolCfg: {
        ${poolCfg.user}.packages = [ poolCfg.packageWithExtensions ];
      }) cfg
    );

    services.phpfpm.pools = lib.mapAttrs (name: poolCfg: {
      phpPackage = poolCfg.packageWithExtensions;
      user = poolCfg.user;

      settings = lib.mkMerge [
        (defaultPoolSettings poolCfg)
        (poolCfg.settings)
      ];

      phpOptions = (defaultPhpOptions name) + (poolCfg.phpOptions);
    }) cfg;
  };
}
