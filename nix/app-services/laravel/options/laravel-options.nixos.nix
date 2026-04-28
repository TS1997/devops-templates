{
  lib,
  pkgs,
  util,
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
      type = util.submodule {
        options = {
          enable = lib.mkEnableOption "Enable Inertia.js Server-Side Rendering server.";

          host = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "The host the Inertia SSR server binds to.";
          };

          port = lib.mkOption {
            type = lib.types.int;
            default = 13714;
            description = "The port the Inertia SSR server listens on.";
          };

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
      default = { };
      description = "Inertia.js SSR configuration.";
    };
  };

  config = {
    inertiaSsr.enable = lib.mkDefault true;
  };
}
