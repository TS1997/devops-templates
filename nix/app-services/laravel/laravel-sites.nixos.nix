{
  config,
  lib,
  pkgs,
  util,
  ...
}:
let
  sites = lib.filterAttrs (_: siteCfg: siteCfg.enable) config.services.ts1997.laravelSites;

  mysqlSites = lib.filterAttrs (
    name: siteCfg: siteCfg.database.enable && siteCfg.database.driver == "mysql"
  ) sites;

  pgsqlSites = lib.filterAttrs (
    name: siteCfg: siteCfg.database.enable && siteCfg.database.driver == "pgsql"
  ) sites;

  redisSites = lib.filterAttrs (name: siteCfg: siteCfg.redis.enable) sites;

  mkDefaultEnv =
    name: siteCfg:
    import ./config/default-env.nix {
      inherit
        config
        lib
        name
        siteCfg
        ;
    };

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
      inherit sites;
    })
    ./submodules/laravel-scheduler.nixos.nix
    ./submodules/laravel-queue-worker.nixos.nix
    ./submodules/laravel-inertia-ssr.nixos.nix
    ./submodules/laravel-migrate.nixos.nix
  ];

  options.services.ts1997.laravelSites = lib.mkOption {
    type = lib.types.attrsOf (
      util.submodule {
        imports = [
          ../options/app-options.base.nix
          ../options/app-options.nixos.nix
          ./options/laravel-options.base.nix
          ./options/laravel-options.nixos.nix
        ];
      }
    );
    default = { };
    description = "Laravel application configuration";
  };

  config = lib.mkIf (sites != { }) {
    system.activationScripts = lib.mkMerge (
      (lib.mapAttrsToList (
        name: siteCfg:
        {
          "setup-laravel-dirs-${name}" = lib.stringAfter [ "users" "groups" ] (
            # If this laravel instance is a nix derivation
            if siteCfg.package != null then
              ''
                install -d -m 0770 -o ${siteCfg.user} -g ${siteCfg.user} \
                  ${siteCfg.workingDir}/storage/app/public \
                  ${siteCfg.workingDir}/storage/framework/cache/data \
                  ${siteCfg.workingDir}/storage/framework/sessions \
                  ${siteCfg.workingDir}/storage/framework/testing \
                  ${siteCfg.workingDir}/storage/framework/views \
                  ${siteCfg.workingDir}/storage/logs \
                  ${siteCfg.workingDir}/bootstrap-cache
              ''
            else
              ''
                mkdir -p ${siteCfg.workingDir}/storage
                chown -R ${siteCfg.user}:${siteCfg.user} ${siteCfg.workingDir}/storage
                chmod -R 0770 ${siteCfg.workingDir}/storage

                mkdir -p ${siteCfg.workingDir}/bootstrap
                chown -R ${siteCfg.user}:${siteCfg.user} ${siteCfg.workingDir}/bootstrap
                chmod -R 0770 ${siteCfg.workingDir}/bootstrap/cache
              ''
          );
        }
      ) sites)
      ++ (lib.mapAttrsToList (
        name: siteCfg:
        lib.mkIf (siteCfg.generateEnv) {
          "generate-env-${name}" = (
            import ../../utils/generate-env.nixos.nix {
              inherit lib pkgs siteCfg;
              defaultEnv = (mkDefaultEnv name siteCfg);
            }
          );
        }
      ) sites)
    );

    services.ts1997.nginx = {
      enable = true;
      virtualHosts = lib.mapAttrs (name: siteCfg: {
        serverName = siteCfg.domain;
        serverAliases = siteCfg.extraDomains;
        root = siteCfg.webRoot;
        forceWWW = siteCfg.forceWWW;
        basicAuthFile = siteCfg.basicAuthFile;
        user = siteCfg.user;
        locations = mkLocations name siteCfg;
      }) sites;
    };

    services.ts1997.phpfpm = {
      enable = true;
      pools = lib.mapAttrs (name: siteCfg: builtins.removeAttrs siteCfg.phpPool [ "fullPackage" ]) sites;
    };

    # php-fpm workers inherit env vars from the pool's systemd unit when
    # clear_env = "no" (the default), so package-deployed sites - which have
    # no .env for Laravel to auto-load - get their config this way instead.
    systemd.services = lib.mkMerge (
      lib.mapAttrsToList (
        name: siteCfg:
        lib.mkIf (siteCfg.package != null) {
          "phpfpm-${name}".serviceConfig.EnvironmentFile = "-${siteCfg.workingDir}/env";
        }
      ) sites
    );


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
