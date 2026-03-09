{ lib, ... }:
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
  };
}
