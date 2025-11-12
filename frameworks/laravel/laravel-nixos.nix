{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.laravel.sites;

  mkLocations =
    name: siteCfg:
    import ./settings/nginx-locations.nix {
      inherit pkgs;
      siteCfg = siteCfg;
      phpSocket = config.services.ts1997.phpPools.${name}.socket;
    };
in
{
  options.services.ts1997.laravel.sites = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, ... }:
        {
          imports = [ ./options/site-options.nix ];
          config = {
            _module.args = { inherit config pkgs lib; };
            workingDir = lib.mkDefault "/var/lib/${config.user}";
          };
        }
      )
    );
    default = { };
    description = "Laravel site configurations.";
  };

  config = lib.mkIf (cfg != { }) {
    users = {
      users = lib.mkMerge (
        lib.mapAttrsToList (name: siteCfg: {
          ${siteCfg.user} = {
            isSystemUser = true;
            createHome = true;
            home = siteCfg.workingDir;
            group = siteCfg.user;
          };
        }) cfg
      );

      groups = lib.mkMerge (
        lib.mapAttrsToList (name: siteCfg: {
          ${siteCfg.user} = {
            members = [
              siteCfg.user
            ];
          };
        }) cfg
      );
    };

    services.ts1997.virtualHosts = lib.mapAttrs (name: siteCfg: {
      user = siteCfg.user;
      root = siteCfg.webRoot;
      serverName = siteCfg.domain;
      serverAliases = siteCfg.extraDomains;
      forceWWW = siteCfg.forceWWW;
      locations = mkLocations name siteCfg;
    }) cfg;

    services.ts1997.phpPools = lib.mapAttrs (name: siteCfg: {
      user = siteCfg.user;
      phpPackage = siteCfg.phpPackage;
    }) cfg;

    services.ts1997.mysql = lib.mkMerge (
      lib.mapAttrsToList (
        name: siteCfg:
        lib.mkIf (siteCfg.database.enable && siteCfg.database.connection == "mysql") {
          ${name} = {
            user = siteCfg.database.user;
            name = siteCfg.database.name;
          };
        }
      ) cfg
    );
  };
}
