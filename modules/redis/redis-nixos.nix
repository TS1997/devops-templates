{
  config,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.redisServers;
in
{
  options.services.ts1997.redisServers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            enable = lib.mkEnableOption "Enable Redis server configuration for this app.";

            user = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "The Redis user for this server.";
            };

            port = lib.mkOption {
              type = lib.types.int;
              default = 0;
              description = "The port on which the Redis server will listen. Leave as 0 to utilize unix socket";
            };

            socket = lib.mkOption {
              type = lib.types.str;
              default = "/run/redis-${name}/redis.sock";
              description = "The unix socket path for the Redis server.";
            };
          };
        }
      )
    );
    default = { };
    description = "List of Redis servers to enable.";
  };

  config = lib.mkIf (cfg != { }) {
    services.redis.servers = lib.mapAttrs (name: serverCfg: {
      enable = serverCfg.enable;
      user = serverCfg.user;
      group = serverCfg.user;
      port = serverCfg.port;
      unixSocket = serverCfg.socket;
      unixSocketPerm = 660;
    }) cfg;
  };
}
