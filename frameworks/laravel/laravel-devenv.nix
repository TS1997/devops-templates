{ config, lib, ... }:
let
  cfg = config.services.ts1997.laravel;
in
{
  options.services.ts1997.laravel = lib.mkOption {
    type = lib.types.submodule (args: {
      imports = [ (import ./options/devenv-options.nix args) ];
    });
    default = { };
    description = "Laravel application configuration.";
  };

  config = lib.mkIf (cfg != { }) {
    services.ts1997.mysql = lib.mkIf (cfg.database.enable && cfg.database.driver == "mysql") {
      enable = cfg.database.enable;
      name = cfg.database.name;

      phpmyadmin = cfg.phpmyadmin;
    };
  };
}
