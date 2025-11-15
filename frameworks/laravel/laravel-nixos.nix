{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ts1997.laravel.sites;

  mkLocations =
    name: siteCfg:
    (import ./config/nginx-locations.nix {
      inherit pkgs siteCfg;
      phpSocket = config.services.ts1997.phpPools.${name}.socket;
    });
in
{
  options.services.ts1997.laravel.sites = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          imports = [
            (import ./options/options.nix {
              inherit
                config
                lib
                pkgs
                name
                ;
              isDevenv = false;
            })
          ];
        }
      )
    );
    default = { };
    description = "Laravel application configurations.";
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
      locations = (mkLocations name siteCfg);
    }) cfg;

    services.ts1997.phpPools = lib.mapAttrs (name: siteCfg: {
      user = siteCfg.user;
      phpPackage = siteCfg.phpPackage;
    }) cfg;

    services.ts1997.mysql = lib.mkMerge (
      lib.mapAttrsToList (
        name: siteCfg:
        lib.mkIf (siteCfg.database.enable && siteCfg.database.driver == "mysql") {
          ${name} = {
            user = siteCfg.database.user;
          };
        }
      ) cfg
    );
  };
}
