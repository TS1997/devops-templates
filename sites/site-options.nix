{
  config,
  lib,
  name,
  ...
}:
{
  options = {
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain name for ${name}.";
    };

    workingDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${name}";
      description = "The working directory for the site ${name}.";
    };

    webRoot = lib.mkOption {
      type = lib.types.str;
      default = "${config.workingDir}/public";
      description = "The web root directory for the site ${name}.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "The user that owns the site files for ${name}.";
    };
  };
}
