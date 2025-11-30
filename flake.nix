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
              ./sites/nixos-sites.nix
              # ./frameworks/nixos.nix
            ];
          };
      };
    };
}
