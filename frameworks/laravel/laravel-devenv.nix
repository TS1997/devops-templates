{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ts1997.laravel;
  pgsqlCfg = config.services.postgres;

  dbCfg = {
    driver = cfg.database.driver;
    host =
      if cfg.database.driver == "pgsql" then pgsqlCfg.settings.unix_socket_directories else "127.0.0.1";
    port = if cfg.database.driver == "pgsql" then pgsqlCfg.settings.port else 3306;
    socket = if cfg.database.driver == "mysql" then config.env.MYSQL_UNIX_PORT else null;
  };

  environmentDefaults = (
    import ./config/env-defaults.nix {
      inherit lib dbCfg;
      siteCfg = cfg;
      redisSocket = config.env.REDIS_UNIX_SOCKET or null;
      isDevenv = true;
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
    env = environmentDefaults // cfg.environment;

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

      phpmyadmin = cfg.phpmyadmin // {
        host = lib.mkDefault cfg.domain;
      };
    };

    services.ts1997.pgsql = lib.mkIf (cfg.database.enable && cfg.database.driver == "pgsql") {
      enable = cfg.database.enable;
      name = cfg.database.name;
      user = cfg.database.user;
      password = cfg.database.password;
      extensions = cfg.database.extensions;
    };

    services.ts1997.redis = lib.mkIf (cfg.redis.enable) {
      enable = cfg.redis.enable;
    };

    services.mailpit = {
      enable = true;
      uiListenAddress = "${cfg.domain}:8025";
    };

    processes = lib.mkMerge [
      (lib.mkIf cfg.scheduler.enable {
        laravel-scheduler.exec = ''
          while true; do
            ${cfg.phpPackage}/bin/php artisan schedule:run --verbose --no-interaction
            sleep 60
          done
        '';
      })

      (lib.mkIf cfg.queue.enable {
        laravel-queue.exec = ''
          ${cfg.phpPackage}/bin/php artisan queue:work \
            --queue=${cfg.queue.connection}
        '';
      })
    ];
  };
}
