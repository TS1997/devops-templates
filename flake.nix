{
  description = "DevOps Templates";
  outputs =
    { self }:
    {
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
