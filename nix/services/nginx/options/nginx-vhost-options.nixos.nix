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

    basicAuthFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/path/to/htpasswd";
      description = "Path to an htpasswd file for HTTP basic authentication on this virtual host.";
    };
  };

  config = {
    root = lib.mkDefault "/var/lib/${name}/public";
  };
}
