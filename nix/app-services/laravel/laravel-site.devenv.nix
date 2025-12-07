{
  config,
  lib,
  util,
  ...
}:
let
  siteCfg = config.services.ts1997.laravelSite;

  defaultEnv = import ./config/default-env.nix {
    inherit config lib siteCfg;
  };

  locations = import ./config/nginx-locations.nix {
    inherit config siteCfg;
    phpSocket = config.languages.php.fpm.pools.web.socket;
  };
in
{
  options.services.ts1997.laravelSite = lib.mkOption {
    type = util.submodule {
      imports = [
        ../options/app-options.base.nix
        ../options/app-options.devenv.nix
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
      virtualHosts.web = {
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
      pools.web = builtins.removeAttrs siteCfg.phpPool [ "fullPackage" ];
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
      phpmyadmin = {
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
    };

    services.ts1997.redis = lib.mkIf (siteCfg.redis.enable) {
      enable = siteCfg.redis.enable;
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
