{
  config,
  lib,
  util,
  ...
}:
let
  cfg = config.services.ts1997.phpfpm;
in
{
  options.services.ts1997.phpfpm = lib.mkOption {
    type = util.submodule {
      imports = [
        ./options/phpfpm-options.base.nix
        ./options/phpfpm-options.nixos.nix
      ];
    };
    description = "PHP-FPM configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    users.users = lib.mkMerge (
      lib.mapAttrsToList (_: poolCfg: {
        ${poolCfg.user}.packages = [ poolCfg.fullPackage ];
      }) cfg.pools
    );

    services.phpfpm = {
      phpPackage = cfg.fullPackage;
      extraConfig = cfg.extraConfig;

      pools = lib.mapAttrs (poolName: poolCfg: {
        extraConfig = poolCfg.extraConfig;
        phpEnv = poolCfg.phpEnv;
        phpOptions = poolCfg.phpOptions + ''
          error_log = /var/log/php-fpm/${poolName}-error.log
        '';
        phpPackage = poolCfg.fullPackage;
        settings = poolCfg.settings // {
          "listen.owner" = "nginx";
          "listen.group" = poolCfg.user;
          "listen.mode" = "0660";
          "php_admin_value[error_log]" = "/var/log/php-fpm/${poolName}-error.log";
        };
        user = poolCfg.user;
      }) cfg.pools;
    };
  };
}
