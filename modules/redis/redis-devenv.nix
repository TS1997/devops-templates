{
  config,
  lib,
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
      port = 0;
    };
  };
}
