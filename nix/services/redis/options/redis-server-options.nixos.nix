{
  lib,
  name,
  ...
}:
{
  options = {
    user = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "The Redis user for this server.";
    };
  };

  config = {
    socket = "/run/redis-${name}/redis.sock";
  };
}
