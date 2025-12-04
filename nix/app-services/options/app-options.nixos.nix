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

    nginx = {
      forceWWW = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to force www prefix for this virtual host.";
      };
    };
  };

  config = {
    workingDir = lib.mkDefault "/var/lib/${name}";
  };
}
