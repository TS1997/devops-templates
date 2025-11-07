{
  config,
  pkgs,
  lib,
  options,
  ...
}:
let
  cfg = config.services.ts1997.phpPools;
  mkDefaultPoolSettings = import ../../settings/phpfpm-settings.nix;

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

        settings = lib.mkMerge [
          (mkDefaultPoolSettings { user = poolCfg.user; })
          (poolCfg.settings or { })
        ];

        phpPackage = lib.mkDefault pkgs.php83;
        phpOptions = (import ../../settings/php-options.nix { inherit name; }) + (poolCfg.phpOptions or "");
      }
    ) cfg;
  };
}
