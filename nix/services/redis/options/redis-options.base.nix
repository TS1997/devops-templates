{
  lib,
  pkgs,
  util,
  ...
}:
{
  options = {
    enable = lib.mkEnableOption "Enable Redis server configuration.";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.redis;
      description = "Package to use for the Redis server.";
    };

    servers = lib.mkOption {
      type = lib.types.attrsOf (
        util.submodule {
          imports = [
            ./redis-server-options.base.nix
          ];
        }
      );
      default = { };
      description = "List of Redis servers to enable.";
    };
  };
}
