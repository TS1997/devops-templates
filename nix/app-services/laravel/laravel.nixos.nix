{
  config,
  lib,
  util,
  ...
}:
let
  cfg = config.services.ts1997.laravelSites;
in
{
  imports = [
    (import ../../modules/users.nixos.nix {
      users = lib.mapAttrs (name: siteCfg: {
        home = siteCfg.workingDir;
      }) cfg;
    })
  ];

  options.services.ts1997.laravelSites = lib.mkOption {
    type = lib.types.attrsOf (
      util.submodule {
        imports = [
          ../options/app-options.common.nix
          ../options/app-options.nixos.nix
        ];
      }
    );
    default = { };
    description = "Laravel application configuration";
  };

  config = lib.mkIf (cfg != { }) {
    services.ts1997.nginx = {
      enable = true;
      virtualHosts = lib.mapAttrs (name: siteCfg: {
        serverName = siteCfg.domain;
        serverAliases = siteCfg.extraDomains;
        root = siteCfg.webRoot;
        forceWWW = siteCfg.nginx.forceWWW;
        user = siteCfg.nginx.user;
        locations."/".extraConfig = [
          ''
            add_header X-Frame-Options "SAMEORIGIN" always;
            add_header X-Content-Type-Options "nosniff" always;
            add_header Content-Type text/plain;
            return 200 "Hello from Nginx\n";
          ''
        ];
      }) cfg;
    };
  };
}
