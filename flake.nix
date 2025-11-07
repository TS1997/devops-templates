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
              ./nixos/modules
              ./nixos/frameworks
            ];
          };
      };
    };
}
