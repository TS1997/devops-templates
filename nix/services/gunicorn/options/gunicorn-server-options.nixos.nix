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
      description = "User to run the Gunicorn server.";
    };
  };

  config = {
    workingDir = lib.mkDefault "/var/lib/${name}";
    socket = lib.mkDefault "/run/gunicorn/${name}.sock";
  };
}
