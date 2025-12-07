{ lib, ... }:
{
  options = {
    scheduler.enable = lib.mkEnableOption "Enable Laravel Scheduler";
  };

  config = {
    scheduler.enable = lib.mkDefault true;
  };
}
