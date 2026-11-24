{ config, lib, ... }:
{
  options = {
    sharedDirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "var/log"
        "public/uploads"
      ];
      description = "Directories relative to `sharedDir` (with their parents) to create for the deploy workflow's `shared_paths`.";
    };
  };

  config = {
    webRoot = lib.mkDefault "${config.currentDir}/public";
    # Overrides the mkDefault true in app-options.base.nix.
    database.enable = lib.mkOverride 900 false;
    redis.enable = lib.mkOverride 900 false;
  };
}
