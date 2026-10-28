{
  description = "DevOps Templates";
  inputs.nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.agenix-rekey = {
    url = "github:oddlama/agenix-rekey";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      agenix-rekey,
    }:
    {
      lib = import ./nix/lib/nixos.nix;

      apps = import ./nix/apps/apps.nix { inherit nixpkgs self flake-utils; };

      agenix-rekey = import ./nix/lib/agenix-rekey.nix { inherit self agenix-rekey; };

      devShells = flake-utils.lib.eachDefaultSystemMap (system: {
        default = import ./nix/lib/devshell.nix {
          pkgs = nixpkgs.legacyPackages.${system};
          agenix-rekey = agenix-rekey.packages.${system}.default;
        };
      });

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
