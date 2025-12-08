{
  config,
  lib,
  util,
  ...
}:
let
  cfg = config.services.ts1997.mailpit;
in
{
  options.services.ts1997.mailpit = lib.mkOption {
    type = util.submodule {
      imports = [
        ./options/mailpit-options.base.nix
      ];
    };
    default = { };
    description = "Mailpit configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    services.mailpit = {
      enable = cfg.enable;
      package = cfg.package;
      additionalArgs = cfg.additionalArgs;
      smtpListenAddress = "${cfg.smtp.host}:${toString cfg.smtp.port}";
      uiListenAddress = "${cfg.ui.host}:${toString cfg.ui.port}";
    };

    processes.mailpit = {
      process-compose = {
        readiness_probe = {
          http_get = {
            host = cfg.ui.host;
            port = cfg.ui.port;
            path = "/";
          };
          initial_delay_seconds = 1;
          period_seconds = 1;
          timeout_seconds = 5;
          success_threshold = 1;
          failure_threshold = 30;
        };
      };
    };

    scripts.mail.exec = "open http://${cfg.ui.host}:${toString cfg.ui.port}";
  };
}
