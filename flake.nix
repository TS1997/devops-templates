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

      templates = {
        wp-base = {
          path = ./nix/templates/braavos-base;
          description = "A wordpress braavos-base template using Nix flake and Devenv.";
        };

        wp-flake = {
          path = ./nix/templates/wp-project;
          description = "A wordpress template using Nix flake and Devenv.";
        };

        laravel = {
          path = ./nix/templates/laravel-project;
          description = "A laravel template using Nix flake and Devenv.";
        };
      };
    };
}
