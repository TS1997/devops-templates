{
  config,
  lib,
  util,
  ...
}:
let
  cfg = config.services.ts1997.redis;
in
{
  options.services.ts1997.redis = lib.mkOption {
    type = util.submodule {
      imports = [
        ./options/redis-options.base.nix
      ];

      options = {
        enable = lib.mkEnableOption "Enable Redis server configuration.";

        servers = lib.mkOption {
          type = lib.types.attrsOf (
            util.submodule {
              imports = [
                ./options/redis-server-options.base.nix
                ./options/redis-server-options.nixos.nix
              ];
            }
          );
          default = { };
          description = "List of Redis servers to enable.";
        };
      };
    };
    default = { };
    description = "Redis server configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    services.redis.servers = lib.mapAttrs (name: serverCfg: {
      enable = serverCfg.enable;
      user = serverCfg.user;
      group = serverCfg.user;
      port = serverCfg.port;
      unixSocket = serverCfg.socket;
      unixSocketPerm = 660;
    }) cfg.servers;
  };
}
