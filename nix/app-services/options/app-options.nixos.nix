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

    database = lib.mkOption {
      # Use lib.types.submodule here instead of util.submodule to avoid circular dependency
      type = lib.types.submodule {
        options = {
          # Database extensions to be installed if using PostgreSQL
          extensions = lib.mkOption {
            type = with lib.types; coercedTo (listOf path) (path: _ignorePg: path) (functionTo (listOf path));
            default = _: [ ];
            example = lib.literalExpression "ps: with ps; [ postgis pg_repack ]";
          };
        };
      };
    };
  };

  config = {
    workingDir = lib.mkDefault "/var/lib/${name}";
    database = {
      name = lib.mkDefault name;
      user = lib.mkDefault name;
    };
  };
}
