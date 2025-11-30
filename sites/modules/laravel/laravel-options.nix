{ lib, ... }:
{
  scheduler = {
    enable = lib.mkEnableOption "Enable Laravel Scheduler";
  };
}
