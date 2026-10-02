{
  description = "DevOps Templates";
  inputs.nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    {
      lib = import ./nix/lib/nixos.nix;

      apps = import ./nix/apps/apps.nix { inherit nixpkgs self flake-utils; };

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
      };
    };
}
