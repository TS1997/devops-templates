{
  config,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.mailpit;
in
{
  options.services.ts1997.mailpit = {
    enable = lib.mkEnableOption "Enable Mailpit service.";

    uiListenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:8025";
      description = "The address and port where the Mailpit web UI will listen.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mailpit = {
      enable = true;
      uiListenAddress = cfg.uiListenAddress;
    };

    scripts = {
      mail.exec = "open http://${cfg.uiListenAddress}/";
    };
  };
}
