{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ts1997.laravel;

  locations = (
    import ./config/nginx-locations.nix {
      inherit pkgs;
      siteCfg = cfg;
      phpSocket = config.languages.php.fpm.pools.web.socket;
    }
  );
in
{
  options.services.ts1997.laravel = lib.mkOption {
    type = lib.types.submodule {
      imports = [
        (import ./options/devenv-options.nix {
          inherit config lib pkgs;
        })
      ];
    };
    default = { };
    description = "Laravel application configuration.";
  };

  config = lib.mkIf (cfg != { }) {
    services.ts1997.nginx = {
      enable = true;
      serverName = cfg.domain;
      serverAliases = cfg.extraDomains;
      root = cfg.webRoot;
      port = cfg.port;
      sslPort = cfg.sslPort;
      enableSsl = cfg.enableSsl;
      locations = locations;
    };

    services.ts1997.php = {
      enable = true;
      phpPackage = cfg.phpPackage;
    };

    services.ts1997.mysql = lib.mkIf (cfg.database.enable && cfg.database.driver == "mysql") {
      enable = cfg.database.enable;
      name = cfg.database.name;

      phpmyadmin = cfg.phpmyadmin;
    };
  };
}
