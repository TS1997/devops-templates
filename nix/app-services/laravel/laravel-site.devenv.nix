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
  };
}
