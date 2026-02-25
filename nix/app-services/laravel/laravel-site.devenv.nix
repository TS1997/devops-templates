{
  config,
  lib,
  util,
  ...
}:
let
  name = "web";
  siteCfg = config.services.ts1997.laravelSite;

  defaultEnv = import ./config/default-env.nix {
    inherit
      config
      lib
      name
      siteCfg
      ;
  };

  locations = import ./config/nginx-locations.nix {
    inherit config siteCfg;
    phpSocket = config.languages.php.fpm.pools.${name}.socket;
  };
in
{
  options.services.ts1997.laravelSite = lib.mkOption {
    type = util.submodule {
      imports = [
        ../options/app-options.base.nix
        ../options/app-options.devenv.nix
        ./options/laravel-options.base.nix
      ];
    };
    default = { };
    description = "Laravel application configuration";
  };

  config = lib.mkIf (siteCfg != { }) {
    env = defaultEnv // siteCfg.env;

    languages.javascript = {
      enable = siteCfg.nodejs.enable;
      package = siteCfg.nodejs.package;
      npm = {
        enable = siteCfg.nodejs.enable;
        install.enable = siteCfg.nodejs.install.enable;
      };
    };

    services.ts1997.nginx = {
      enable = true;
      virtualHosts.${name} = {
        serverName = siteCfg.domain;
        serverAliases = siteCfg.extraDomains;
        root = siteCfg.webRoot;
        port = siteCfg.port;
        sslPort = siteCfg.sslPort;
        enableSsl = siteCfg.enableSsl;
        locations = locations;
      };
    };

    services.ts1997.phpfpm = {
      enable = true;
      basePackage = siteCfg.phpPool.basePackage;
      extensions = siteCfg.phpPool.extensions;
      composer.install.enable = siteCfg.composer.install.enable;
      pools.${name} = builtins.removeAttrs siteCfg.phpPool [ "fullPackage" ];
    };

    services.ts1997.mysql = lib.mkIf (siteCfg.database.enable && siteCfg.database.driver == "mysql") {
      enable = true;
      databases = [
        {
          name = siteCfg.database.name;
          user = siteCfg.database.user;
          password = siteCfg.database.password;
        }
      ];
      phpMyAdmin = {
        enable = siteCfg.database.admin.enable;
        host = siteCfg.domain;
      };
    };

    services.ts1997.pgsql = lib.mkIf (siteCfg.database.enable && siteCfg.database.driver == "pgsql") {
      enable = true;
      databases = [
        {
          name = siteCfg.database.name;
          user = siteCfg.database.user;
          extensions = siteCfg.database.extensions;
        }
      ];
      pgAdmin = {
        enable = siteCfg.database.admin.enable;
        host = siteCfg.domain;
      };
    };

    services.ts1997.redis = lib.mkIf (siteCfg.redis.enable) {
      enable = siteCfg.redis.enable;
      servers.${name} = {
        enable = siteCfg.redis.enable;
      };
    };

    services.ts1997.mailpit = lib.mkIf (siteCfg.mailpit.enable) {
      enable = siteCfg.mailpit.enable;
      smtp.host = siteCfg.domain;
      ui.host = siteCfg.domain;
    };

    processes = lib.mkMerge [
      (lib.mkIf (siteCfg.nodejs.enable) {
        nodejs.exec = siteCfg.nodejs.script;
      })

      (lib.mkIf (siteCfg.scheduler.enable) {
        scheduler.exec = "php artisan schedule:work";
      })

      (lib.mkIf (siteCfg.queue.enable) {
        queue = {
          exec = ''
            php artisan queue:work ${siteCfg.queue.connection} \
              --timeout=${toString siteCfg.queue.timeout} \
              --sleep=${toString siteCfg.queue.sleep} \
              --tries=${toString siteCfg.queue.tries} \
              --max-jobs=${toString siteCfg.queue.maxJobs} \
              --max-time=${toString siteCfg.queue.maxTime}
          '';
          process-compose = {
            availability = {
              restart = "on_failure";
            };
            depends_on = lib.mkMerge [
              (lib.mkIf (siteCfg.database.enable && siteCfg.database.driver == "mysql") {
                mysql.condition = "process_healthy";
              })
              (lib.mkIf (siteCfg.database.enable && siteCfg.database.driver == "pgsql") {
                postgres.condition = "process_healthy";
              })
              (lib.mkIf siteCfg.redis.enable {
                redis.condition = "process_healthy";
              })
            ];
          };
        };
      })
    ];

    scripts = {
      run-tests.exec = ''
        # Load environment variables from phpunit.xml
        while IFS= read -r line; do
          name=$(echo "$line" | sed -En 's/.*name="([^"]+)".*/\1/p')
          value=$(echo "$line" | sed -En 's/.*value="([^"]*)".*/\1/p')

          if [ -n "$name" ]; then
            export "$name"="$value"
          fi
        done < <(grep -E '<env[[:space:]]+name=' phpunit.xml)

        # Run the tests
        php artisan test "$@"
      '';
    };
  };
}
