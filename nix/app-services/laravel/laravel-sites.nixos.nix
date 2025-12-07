{
  config,
  lib,
  util,
  ...
}:
let
  sites = config.services.ts1997.laravelSites;

  mysqlSites = lib.filterAttrs (
    name: siteCfg: siteCfg.database.enable && siteCfg.database.driver == "mysql"
  ) sites;

  pgsqlSites = lib.filterAttrs (
    name: siteCfg: siteCfg.database.enable && siteCfg.database.driver == "pgsql"
  ) sites;

  redisSites = lib.filterAttrs (name: siteCfg: siteCfg.redis.enable) sites;

  mkLocations =
    name: siteCfg:
    import ./config/nginx-locations.nix {
      inherit config siteCfg;
      phpSocket = config.services.phpfpm.pools.${name}.socket;
    };
in
{
  imports = [
    (import ../../modules/users.nixos.nix {
      users = lib.mapAttrs (name: siteCfg: {
        home = siteCfg.workingDir;
      }) sites;
    })
  ];

  options.services.ts1997.laravelSites = lib.mkOption {
    type = lib.types.attrsOf (
      util.submodule {
        imports = [
          ../options/app-options.base.nix
          ../options/app-options.nixos.nix
        ];
      }
    );
    default = { };
    description = "Laravel application configuration";
  };

  config = lib.mkIf (sites != { }) {
    services.ts1997.nginx = {
      enable = true;
      virtualHosts = lib.mapAttrs (name: siteCfg: {
        serverName = siteCfg.domain;
        serverAliases = siteCfg.extraDomains;
        root = siteCfg.webRoot;
        forceWWW = siteCfg.forceWWW;
        user = siteCfg.user;
        locations = mkLocations name siteCfg;
      }) sites;
    };

    services.ts1997.phpfpm = {
      enable = true;
      pools = lib.mapAttrs (name: siteCfg: builtins.removeAttrs siteCfg.phpPool [ "fullPackage" ]) sites;
    };

    services.ts1997.mysql = lib.mkIf (mysqlSites != { }) {
      enable = true;
      databases = lib.mapAttrsToList (_: siteCfg: {
        name = siteCfg.database.name;
        user = siteCfg.database.user;
      }) mysqlSites;
    };

    services.ts1997.pgsql = lib.mkIf (pgsqlSites != { }) {
      enable = true;
      databases = lib.mapAttrsToList (_: siteCfg: {
        name = siteCfg.database.name;
        user = siteCfg.database.user;
        extensions = siteCfg.database.extensions;
      }) pgsqlSites;
    };

    services.ts1997.redis = lib.mkIf (redisSites != { }) {
      enable = true;
      servers = lib.mapAttrs (name: siteCfg: {
        enable = siteCfg.redis.enable;
        user = name;
      }) redisSites;
    };
  };
}
