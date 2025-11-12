{
  description = "DevOps Templates";
  outputs =
    { self }:
    {
      nixosModules = {
        default =
          { ... }:
          {
            imports = [
              ./modules/nixos.nix
              ./frameworks/nixos.nix
            ];
          };
      };
    };
}
