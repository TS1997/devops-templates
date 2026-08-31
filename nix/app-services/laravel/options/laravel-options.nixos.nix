{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = ''
        Pre-built Laravel application derivation to serve (e.g. the output of
        a site's own package.nix built with php.buildComposerProject).

        When set, the site is deployed as an immutable, read-only package
        instead of a mutable rsync'd checkout: webRoot is derived from this
        package, and workingDir is used purely as the site's mutable data
        directory (storage, bootstrap cache, generated env file) rather than
        holding the application code.

        The derivation is EXPECTED to symlink its own storage/ and
        bootstrap/cache directories out to workingDir (passed to it as its
        dataDir). This is done via derivation passThru.
      '';
    };

    migrate.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to run "php artisan migrate --force" as a oneshot systemd
        service whenever the site's package derivation changes (i.e. on
        every deploy that ships new code). Only applies when package is set
        - rsync-deployed sites already run migrations from the CI deploy
        workflow instead.
      '';
    };

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

  config = {
    webRoot = lib.mkDefault (
      if config.package != null then "${config.package}/public" else "${config.workingDir}/public"
    );
  };
}
