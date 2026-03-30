{
  config,
  lib,
  pkgs,
  util,
  ...
}:
let
  sites = lib.filterAttrs (_: siteCfg: siteCfg.enable) config.services.ts1997.wordpressSites;

  mysqlSites = lib.filterAttrs (name: siteCfg: siteCfg.database.enable) sites;
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
      inherit config lib siteCfg;
      phpSocket = config.services.phpfpm.pools.${name}.socket;
    };
in
{
  imports = [
    (import ../../modules/users.nixos.nix {
      inherit sites;
    })
  ];

  options.services.ts1997.wordpressSites = lib.mkOption {
    type = lib.types.attrsOf (
      util.submodule {
        imports = [
          ../options/app-options.base.nix
          ../options/app-options.nixos.nix
          ./options/wordpress-options.base.nix
          ./options/wordpress-options.nixos.nix
        ];
      }
    );
    default = { };
    description = "WordPress sites configuration";
  };

  config = lib.mkIf (sites != { }) {
    system.activationScripts = lib.mkMerge (
      (lib.mapAttrsToList (name: siteCfg: {
        "setup-wordpress-dirs-${name}" = lib.stringAfter [ "users" "groups" ] ''
          mkdir -p ${siteCfg.workingDir}
          chown -R ${siteCfg.user}:${siteCfg.user} ${siteCfg.workingDir}
          chmod -R 0750 ${siteCfg.workingDir}

          # Persistent uploads directory - path must match the site's .env
          mkdir -p ${siteCfg.uploadsDir}
          chown -R ${siteCfg.user}:${siteCfg.user} ${siteCfg.uploadsDir}
          chmod -R 0755 ${siteCfg.uploadsDir}
        '';
      }) sites)
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

    services.ts1997.mysql = lib.mkIf (mysqlSites != { }) {
      enable = true;
      databases = lib.mapAttrsToList (_: siteCfg: {
        name = siteCfg.database.name;
        user = siteCfg.database.user;
      }) mysqlSites;
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
