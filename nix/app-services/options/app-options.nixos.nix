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

    phpPool = lib.mkOption {
      # Use lib.types.submodule here instead of util.submodule to avoid circular dependency
      type = lib.types.submodule {
        imports = [ ../../services/phpfpm/options/phpfpm-pool-options.nixos.nix ];

        config = {
          user = lib.mkDefault name;
        };
      };
    };
  };

  config = {
    workingDir = lib.mkDefault "/var/lib/${name}";
  };
}
