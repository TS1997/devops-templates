{
  description = "DevOps Templates";
  outputs =
    { self }:
    {
      nixosModules = {
        default = {
          imports = [
            (import ./utils/util.nix { })
            ./modules/nixos.nix
            ./frameworks/nixos.nix
          ];
        };
      };
    };
}
