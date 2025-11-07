{
  config,
  pkgs,
  lib,
  options,
  ...
}:
let
  cfg = config.services.ts1997.phpPools;
  defaultPoolSettings = import ../../settings/phpfpm-settings.nix;
in
{
  options.services.ts1997.phpPools = options.services.phpfpm.pools;

  config = lib.mkIf (cfg != { }) {
    services.phpfpm = {
      enable = true;
      pools = lib.mapAttrs (
        name: poolCfg:
        {
          settings = lib.mkMerge [
            (defaultPoolSettings)
            {
              "listen.owner" = lib.mkDefault "nginx";
              "listen.group" = lib.mkDefault poolCfg.user;
              "listen.mode" = lib.mkDefault "0660";
            }
            (poolCfg.settings or { })
          ];

          phpOptions = lib.mkMerge [
            (import ../../settings/php-options.nix { inherit name; })
            (poolCfg.phpOptions or "")
          ];

          phpPackage = lib.mkDefault pkgs.php83;

          user = poolCfg.user;
          group = lib.mkDefault poolCfg.user;
        }
        // poolCfg
      ) cfg;
    };
  };
}
