{
  description = "DevOps Templates";
  outputs =
    { self }:
    {
      lib = import ./nix/lib/nixos.nix;

      nixosModules = {
        default = {
          imports = [
            (import ./nix/utils/util.nix { })
            ./nix/services/nixos.nix
            ./nix/app-services/nixos.nix
          ];
        };
      };
    };
}
