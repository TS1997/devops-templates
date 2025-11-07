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
              ./modules
              ./frameworks
            ];
          };
      };
    };
}
