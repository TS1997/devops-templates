{
  lib,
  pkgs,
  ...
}:
{
  options = {
    scheduler.packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages to include in the Laravel Scheduler service environment.";
    };

    queue = lib.mkOption {
      # Use lib.types.submodule here instead of util.submodule to avoid circular dependency
      type = lib.types.submodule {
        options = {
          packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
            description = "Additional packages to include in the Laravel Queue Worker service environment.";
          };
        };
      };
    };

    inertiaSsr = lib.mkOption {
      # Use lib.types.submodule here instead of util.submodule to avoid circular dependency
      type = lib.types.submodule {
        options = {
          command = lib.mkOption {
            type = lib.types.str;
            default = "php artisan inertia:start-ssr";
            description = "Command used to start the Inertia SSR server.";
          };

          packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
            description = "Additional packages to include in the Inertia SSR service environment.";
          };

          nodejs = lib.mkOption {
            type = lib.types.nullOr lib.types.package;
            default = pkgs.nodejs_24;
            description = "Node.js package used by the Inertia SSR service. Defaults to pkgs.nodejs_24 when null.";
          };
        };
      };
    };
  };
}
