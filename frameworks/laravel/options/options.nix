{
  config,
  lib,
  pkgs,
  isDevenv,
  name ? null,
  ...
}:
let
  devenvOptions = import ../../options/devenv-options.nix {
    inherit config lib pkgs;
  };

  nixosOptions = import ../../options/nixos-options.nix {
    inherit
      config
      lib
      pkgs
      name
      ;
  };
in
{
  imports = lib.optional isDevenv devenvOptions ++ lib.optional (!isDevenv) nixosOptions;

  options = {
    scheduler.enable = lib.mkEnableOption "Enable Laravel Scheduler";

    queue = {
      enable = lib.mkEnableOption "Enable Laravel Queue Worker";

      connection = lib.mkOption {
        type = lib.types.str;
        default = "redis";
        description = "The queue connection to use for the Laravel Queue Worker.";
      };

      workers = lib.mkOption {
        type = lib.types.int;
        default = 1;
        description = "The number of queue worker instances to run.";
      };
    };
  };

  config = {
    redis.enable = lib.mkDefault true;
    scheduler.enable = lib.mkDefault true;
    queue.enable = lib.mkDefault true;
  };
}
