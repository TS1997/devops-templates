{
  config,
  lib,
  util,
  ...
}:
let
  siteCfg = config.services.ts1997.laravelSite;
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
        locations."/".extraConfig = ''
          return 200 "Hello from Nginx\n";
          add_header Content-Type text/plain;
        '';
      };
    };
  };
}
