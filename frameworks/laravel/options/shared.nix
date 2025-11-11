{ lib, ... }:
{
  options = {
    scheduler.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Laravel scheduler for this site.";
    };
  };
}
