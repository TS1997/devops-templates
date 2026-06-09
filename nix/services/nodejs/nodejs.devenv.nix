{
  config,
  lib,
  util,
  ...
}:
let
  cfg = config.services.ts1997.nodejs;
in
{
  options.services.ts1997.nodejs = lib.mkOption {
    type = util.submodule {
      imports = [ ./options/nodejs-options.devenv.nix ];
    };
    default = { };
    description = "Node.js development tooling configuration.";
  };

  config = lib.mkIf cfg.enable {
    languages.javascript = {
      enable = cfg.enable;
      package = cfg.package;
      npm = {
        enable = cfg.enable;
        install.enable = cfg.install.enable;
      };
    };

    processes = lib.mkIf (cfg.script != null) {
      nodejs.exec = cfg.script;
    };
  };
}
