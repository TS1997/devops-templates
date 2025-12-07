{
  lib,
  ...
}:
{
  options = {
    enable = lib.mkEnableOption "Enable Redis server.";

    port = lib.mkOption {
      type = lib.types.port;
      default = 0;
      description = "Port for the Redis server. Set to 0 to disable TCP and use only Unix socket.";
    };

    socket = lib.mkOption {
      type = lib.types.str;
      description = "Unix socket for the Redis server.";
      readOnly = true;
    };
  };
}
