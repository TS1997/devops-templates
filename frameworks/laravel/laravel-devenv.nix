{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.laravel;
in
{
  options.services.ts1997.laravel = lib.mkOption {
    type = lib.types.submodule (
      { config, ... }:
      {
        imports = [ ./options/site-options.nix ];
        _module.args = { inherit config pkgs lib; };
      }
    );
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
      locations = import ./settings/nginx-locations.nix {
        inherit pkgs;
        siteCfg = cfg;
        phpSocket = config.languages.php.fpm.pools.web.socket;
      };
    };

    services.ts1997.php = {
      phpPackage = cfg.phpPackage;
    };

    services.ts1997.mysql = lib.mkIf (cfg.database.enable && cfg.database.connection == "mysql") {
      name = cfg.database.name;
      user = cfg.database.user;
      password = cfg.database.password;
    };
  };
}
