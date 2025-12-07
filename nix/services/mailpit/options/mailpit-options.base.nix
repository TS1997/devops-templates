{
  lib,
  pkgs,
  util,
  ...
}:
{
  options = {
    enable = lib.mkEnableOption "Enable Mailpit service.";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.mailpit;
      description = "The Mailpit package to use.";
    };

    additionalArgs = lib.mkOption {
      type = lib.types.listOf (lib.types.lines);
      default = [ ];
      description = "Additional arguments to pass to Mailpit.";
    };

    smtp = lib.mkOption {
      type = util.submodule {
        options = {
          host = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "SMTP server host.";
          };

          port = lib.mkOption {
            type = lib.types.int;
            default = 1025;
            description = "SMTP server port.";
          };
        };
      };
      default = { };
      description = "SMTP server configuration.";
    };

    ui = lib.mkOption {
      type = util.submodule {
        options = {
          host = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "UI server host.";
          };

          port = lib.mkOption {
            type = lib.types.int;
            default = 8025;
            description = "UI server port.";
          };
        };
      };
      default = { };
      description = "UI server configuration.";
    };
  };
}
