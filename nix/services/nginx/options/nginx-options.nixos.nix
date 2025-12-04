{
  lib,
  ...
}:
{
  options = {
    virtualHosts = lib.mkOption {
      # Use lib.types.submodule here instead of util.submodule to avoid circular dependency
      type = lib.types.attrsOf (
        lib.types.submodule {
          imports = [
            ./nginx-vhost-options.nixos.nix
          ];
        }
      );
    };

  };
}
