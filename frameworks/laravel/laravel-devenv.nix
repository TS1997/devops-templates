{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ts1997.laravel;
  phpCfg = config.services.ts1997.php;
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

      config = {
        nodejs.enable = lib.mkDefault true;
      };
    };
    default = { };
    description = "Laravel application configuration.";
  };

  config = lib.mkIf (cfg != { }) {
    env = environmentDefaults // cfg.environment;

    packages = with pkgs; [
      cfg.nodejs.package
      jq
    ];

    languages.javascript.enable = cfg.nodejs.enable;

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

    services.ts1997.php = (builtins.removeAttrs cfg.php [ "packageWithExtensions" ]) // {
      enable = true;
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

    services.ts1997.mailpit = {
      enable = true;
      uiListenAddress = "${cfg.domain}:8025";
    };

    processes = lib.mkMerge [
      (lib.mkIf (cfg.nodejs.enable) {
        vite.exec = "npm run dev";
      })

      (lib.mkIf cfg.scheduler.enable {
        laravel-scheduler.exec = "${phpCfg.packageWithExtensions}/bin/php artisan schedule:work";
      })

      (lib.mkIf cfg.queue.enable {
        laravel-queue.exec = ''
          sleep 2; # Wait for the database to be ready 
          ${phpCfg.packageWithExtensions}/bin/php artisan queue:work ${cfg.queue.connection}
        '';
      })
    ];

    scripts = {
      run-tests.exec = ''
        # Load environment variables from phpunit.xml
        while IFS= read -r line; do
          name=$(echo "$line" | sed -n 's/.*name="\([^"]*\)".*/\1/p')
          value=$(echo "$line" | sed -n 's/.*value="\([^"]*\)".*/\1/p')
          
          export "$name"="$value"
        done < <(grep '<env ' phpunit.xml)

        # Run the tests
        php artisan test "$@"
      '';
    };
  };
}
