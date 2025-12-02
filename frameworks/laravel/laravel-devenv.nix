{
  config,
  lib,
  pkgs,
  util,
  ...
}:
let
  siteCfg = config.services.ts1997.laravel;
  phpCfg = config.services.ts1997.php;
  pgsqlCfg = config.services.postgres;

  dbCfg = {
    driver = siteCfg.database.driver;
    host =
      if siteCfg.database.driver == "pgsql" then
        pgsqlCfg.settings.unix_socket_directories
      else
        "127.0.0.1";
    port = if siteCfg.database.driver == "pgsql" then pgsqlCfg.settings.port else 3306;
    socket = if siteCfg.database.driver == "mysql" then config.env.MYSQL_UNIX_PORT else null;
  };

  environmentDefaults = (
    import ./config/env-defaults.nix {
      inherit lib siteCfg dbCfg;
      redisSocket = config.env.REDIS_UNIX_SOCKET or null;
      isDevenv = true;
    }
  );

  locations = (
    import ./config/nginx-locations.nix {
      inherit pkgs siteCfg;
      phpSocket = config.languages.php.fpm.pools.web.socket;
    }
  );
in
{
  options.services.ts1997.laravel = lib.mkOption {
    type = util.submoduleWithPkgs {
      imports = [
        ../site-options/devenv-options.nix
        ./laravel-options.nix
      ];

      config = {
        nodejs.enable = lib.mkDefault true;
      };
    };
    default = { };
    description = "Laravel application configuration.";
  };

  config = lib.mkIf (siteCfg != { }) {
    env = environmentDefaults // siteCfg.environment;

    packages = with pkgs; [
      siteCfg.nodejs.package
      jq
    ];

    languages.javascript.enable = siteCfg.nodejs.enable;
    services.ts1997.nginx = {
      enable = true;
      serverName = siteCfg.domain;
      serverAliases = siteCfg.extraDomains;
      root = siteCfg.webRoot;
      port = siteCfg.port;
      sslPort = siteCfg.sslPort;
      enableSsl = siteCfg.enableSsl;
      locations = locations;
    };

    services.ts1997.php = (builtins.removeAttrs siteCfg.php [ "packageWithExtensions" ]) // {
      enable = true;
    };

    services.ts1997.mysql = lib.mkIf (siteCfg.database.enable && siteCfg.database.driver == "mysql") {
      enable = siteCfg.database.enable;
      name = siteCfg.database.name;
      user = siteCfg.database.user;
      password = siteCfg.database.password;

      phpmyadmin = siteCfg.phpmyadmin // {
        host = lib.mkDefault siteCfg.domain;
      };
    };

    services.ts1997.pgsql = lib.mkIf (siteCfg.database.enable && siteCfg.database.driver == "pgsql") {
      enable = siteCfg.database.enable;
      name = siteCfg.database.name;
      user = siteCfg.database.user;
      password = siteCfg.database.password;
      extensions = siteCfg.database.extensions;
    };

    services.ts1997.redis = lib.mkIf (siteCfg.redis.enable) {
      enable = siteCfg.redis.enable;
    };

    services.ts1997.mailpit = {
      enable = true;
      uiListenAddress = "${siteCfg.domain}:8025";
    };

    processes = lib.mkMerge [
      (lib.mkIf (siteCfg.nodejs.enable) {
        vite.exec = "npm run dev";
      })

      (lib.mkIf siteCfg.scheduler.enable {
        laravel-scheduler.exec = "${phpCfg.packageWithExtensions}/bin/php artisan schedule:work";
      })

      (lib.mkIf siteCfg.queue.enable {
        laravel-queue.exec = ''
          sleep 2; # Wait for the database to be ready 
          ${phpCfg.packageWithExtensions}/bin/php artisan queue:work ${siteCfg.queue.connection}
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
