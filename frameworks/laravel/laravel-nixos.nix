{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ts1997.laravel.sites;
  redisCfg = config.services.ts1997.redisServers;

  mkEnvironmentDefaults =
    name: siteCfg:
    (import ./config/env-defaults.nix {
      inherit lib siteCfg;
      dbSocket = "/run/mysqld/mysqld.sock";
      redisSocket = redisCfg.${name}.socket or null;
    });

  mkDeploy =
    name: siteCfg:
    (import ./scripts/nixos/deploy.nix {
      inherit
        lib
        pkgs
        name
        siteCfg
        ;
      environmentDefaults = (mkEnvironmentDefaults name siteCfg);
    });

  mkLocations =
    name: siteCfg:
    (import ./config/nginx-locations.nix {
      inherit pkgs siteCfg;
      phpSocket = config.services.ts1997.phpPools.${name}.socket;
    });
in
{
  imports = [
    ./nixos/laravel-scheduler.nix
    ./nixos/laravel-queue-worker.nix
  ];

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

    environment.systemPackages = lib.flatten [
      (lib.mapAttrsToList (name: siteCfg: (mkDeploy name siteCfg)) cfg)
    ];

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

    services.ts1997.redisServers = lib.mkMerge (
      lib.mapAttrsToList (
        name: siteCfg:
        lib.mkIf siteCfg.redis.enable {
          ${name} = {
            user = siteCfg.user;
          };
        }
      ) cfg
    );

    services.ts1997.laravel.scheduler = lib.mkMerge (
      lib.mapAttrsToList (
        name: siteCfg:
        lib.mkIf siteCfg.scheduler.enable {
          ${name} = {
            user = siteCfg.user;
            workingDir = siteCfg.workingDir;
            phpPackage = siteCfg.phpPackage;
            appName = siteCfg.appName;
          };
        }
      ) cfg
    );

    services.ts1997.laravel.queue = lib.mkMerge (
      lib.mapAttrsToList (
        name: siteCfg:
        lib.mkIf siteCfg.queue.enable {
          ${name} = {
            user = siteCfg.user;
            workingDir = siteCfg.workingDir;
            phpPackage = siteCfg.phpPackage;
            appName = siteCfg.appName;
            connection = siteCfg.queue.connection;
            workers = siteCfg.queue.workers;
          };
        }
      ) cfg
    );
  };
}
