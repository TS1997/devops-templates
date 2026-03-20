{
  config,
  lib,
  util,
  ...
}:
let
  name = "web";
  siteCfg = config.services.ts1997.wordpressSite;

  defaultEnv = import ./config/default-env.nix {
    inherit
      config
      lib
      name
      siteCfg
      ;
  };

  locations = import ./config/nginx-locations.nix {
    inherit config lib siteCfg;
    phpSocket = config.languages.php.fpm.pools.${name}.socket;
  };
in
{
  options.services.ts1997.wordpressSite = lib.mkOption {
    type = util.submodule {
      imports = [
        ../options/app-options.base.nix
        ../options/app-options.devenv.nix
        ./options/wordpress-options.base.nix
      ];
    };
    default = { };
    description = "WordPress site configuration";
  };

  config = lib.mkIf (siteCfg.enable) {
    env = defaultEnv // siteCfg.env;

    languages.javascript = {
      enable = siteCfg.nodejs.enable;
      package = siteCfg.nodejs.package;
      npm = {
        enable = siteCfg.nodejs.enable;
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
      pools.${name} = builtins.removeAttrs siteCfg.phpPool [ "fullPackage" ];
    };

    # WordPress requires MySQL
    services.ts1997.mysql = lib.mkIf siteCfg.database.enable {
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

    services.ts1997.redis = lib.mkIf siteCfg.redis.enable {
      enable = siteCfg.redis.enable;
      servers.${name} = {
        enable = siteCfg.redis.enable;
      };
    };

    services.ts1997.mailpit = lib.mkIf siteCfg.mailpit.enable {
      enable = siteCfg.mailpit.enable;
      smtp.host = siteCfg.domain;
      ui.host = siteCfg.domain;
    };

    processes = lib.mkIf siteCfg.nodejs.enable {
      nodejs.exec = siteCfg.nodejs.script;
    };
  };
}
