{
  config,
  lib,
  options,
  ...
}:
let
  cfg = config.services.ts1997.redis;
in
{
  options.services.ts1997.redisServers = options.services.redis.servers;

  config = lib.mkIf (cfg != { }) {
    services.redis.servers = lib.mapAttrs (
      name: serverCfg:
      {
        enable = lib.mkDefault true;
        user = lib.mkDefault "redis";
        group = lib.mkDefault "redis";
        port = lib.mkDefault 0;
        unixSocket = lib.mkDefault "/run/redis-${name}/redis.sock";
        unixSocketPerm = lib.mkDefault 660;
      }
      // serverCfg
    ) cfg;
  };
}
