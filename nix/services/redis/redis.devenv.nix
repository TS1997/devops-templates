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
        servers = lib.mkOption {
          # Use lib.types.submodule here instead of util.submodule to avoid circular dependency
          type = lib.types.attrsOf (
            lib.types.submodule {
              imports = [
                ./options/redis-server-options.devenv.nix
              ];
            }
          );
        };
      };
    };
    default = { };
    description = "Redis server configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    services.redis = {
      enable = cfg.enable;
      package = cfg.package;
      port = cfg.servers.web.port;
    };
  };
}
