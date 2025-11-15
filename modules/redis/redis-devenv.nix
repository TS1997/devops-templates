{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ts1997.redis;
in
{
  options.services.ts1997.redis = {
    enable = lib.mkEnableOption "Enable Redis database.";
  };

  config = lib.mkIf cfg.enable {
    services.redis = {
      enable = true;
      package = pkgs.redis;
      port = 0;
    };
  };
}
