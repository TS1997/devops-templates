{ lib, ... }:
{
  options = {
    pools = lib.mkOption {
      # Use lib.types.submodule here instead of util.submodule to avoid circular dependency
      type = lib.types.attrsOf (
        lib.types.submodule {
          imports = [ ./phpfpm-pool-options.nixos.nix ];
        }
      );
    };
  };
}
