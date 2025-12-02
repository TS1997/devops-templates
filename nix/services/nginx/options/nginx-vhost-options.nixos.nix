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
      description = "The system user to run the nginx worker processes as.";
    };

    forceWWW = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to force www prefix for this virtual host.";
    };
  };

  config = {
    root = lib.mkDefault "/var/lib/${name}/public";
  };
}
