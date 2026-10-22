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
  opensearchSites = lib.filterAttrs (name: siteCfg: siteCfg.opensearch.enable) sites;

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

  # Directories below `base` down to and including `path`, so intermediate
  # directories (e.g. public/ and public/content/) get explicit tmpfiles rules
  # instead of being created as root.
  dirsBelow =
    base: path:
    if path == base || !(lib.hasPrefix "${base}/" path) then
      [ ]
    else
      dirsBelow base (dirOf path) ++ [ path ];

  mkTmpfilesRules =
    siteCfg:
    let
      owner = "${siteCfg.user} ${siteCfg.user}";
      inWorkingDir = lib.hasPrefix "${siteCfg.workingDir}/" siteCfg.uploadsDir;
      dirs = lib.unique (
        dirsBelow siteCfg.workingDir siteCfg.webRoot
        ++ dirsBelow siteCfg.workingDir (dirOf siteCfg.uploadsDir)
      );
    in
    [ "d ${siteCfg.workingDir} 0750 ${owner} -" ]
    ++ map (dir: "d ${dir} 0750 ${owner} -") dirs
    # Persistent uploads directory - path must match the site's .env
    ++ [ "d ${siteCfg.uploadsDir} 0755 ${owner} -" ]
    # Re-own everything on boot and on every switch (sysinit-reactivation),
    # leaving file modes untouched.
    ++ [ "Z ${siteCfg.workingDir} - ${owner} -" ]
    ++ lib.optional (!inWorkingDir) "Z ${siteCfg.uploadsDir} - ${owner} -";
in
{
  imports = [
    (import ../../modules/users.nixos.nix {
      inherit sites;
    })
    ./submodules/wordpress-elasticpress-sync.nixos.nix
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
    systemd.tmpfiles.rules = lib.concatMap mkTmpfilesRules (lib.attrValues sites);

    system.activationScripts = lib.mkMerge (
      lib.mapAttrsToList (
        name: siteCfg:
        lib.mkIf (siteCfg.generateEnv) {
          "generate-env-${name}" = (
            import ../../utils/generate-env.nixos.nix {
              inherit lib pkgs siteCfg;
              defaultEnv = (mkDefaultEnv name siteCfg);
            }
          );
        }
      ) sites
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

    services.ts1997.opensearch = lib.mkIf (opensearchSites != { }) {
      enable = true;
    };
  };
}
