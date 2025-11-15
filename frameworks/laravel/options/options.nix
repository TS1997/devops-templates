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
  };

  config = {
    redis.enable = lib.mkDefault true;
    scheduler.enable = lib.mkDefault true;
  };
}
