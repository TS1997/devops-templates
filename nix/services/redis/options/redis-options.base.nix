{
  lib,
  pkgs,
  ...
}:
{
  options = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.redis;
      description = "Package to use for the Redis server.";
    };
  };
}
