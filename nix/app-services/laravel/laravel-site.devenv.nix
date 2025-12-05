{
  config,
  lib,
  util,
  ...
}:
let
  siteCfg = config.services.ts1997.laravelSite;

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
      basePackage = siteCfg.php.basePackage;
      extensions = siteCfg.php.extensions;
      pools.web = builtins.removeAttrs siteCfg.php [ "fullPackage" ];
    };
  };
}
