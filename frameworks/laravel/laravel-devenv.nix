{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ts1997.laravel;

  environmentDefaults = (
    import ./config/env-defaults.nix {
      inherit lib;
      siteCfg = cfg;
      dbSocket = config.env.MYSQL_UNIX_PORT;
      redisSocket = config.env.REDIS_UNIX_SOCKET;
    }
  );

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
        (import ./options/options.nix {
          inherit config lib pkgs;
          isDevenv = true;
        })
      ];
    };
    default = { };
    description = "Laravel application configuration.";
  };

  config = lib.mkIf (cfg != { }) {
    env = lib.mkMerge [
      environmentDefaults
      cfg.environment
    ];

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
      user = cfg.database.user;
      password = cfg.database.password;

      phpmyadmin = cfg.phpmyadmin;
    };

    services.ts1997.redis = lib.mkIf (cfg.redis.enable) {
      enable = cfg.redis.enable;
    };
  };
}
