{
  config,
  lib,
  pkgs,
  util,
  ...
}:
let
  sites = lib.filterAttrs (_: siteCfg: siteCfg.enable) config.services.ts1997.symfonySites;

  backupSites = lib.filterAttrs (name: siteCfg: siteCfg.backup.enable) sites;

  mkLocations =
    name: siteCfg:
    import ./config/nginx-locations.nix {
      inherit config siteCfg;
      phpSocket = config.services.phpfpm.pools.${name}.socket;
    };

  # "a/b/c" -> [ "a" "a/b" "a/b/c" ], so parents aren't created as root.
  withParents =
    relativePath:
    let
      segments = lib.splitString "/" relativePath;
    in
    lib.genList (index: lib.concatStringsSep "/" (lib.take (index + 1) segments)) (lib.length segments);

  mkTmpfilesRules =
    siteCfg:
    let
      owner = "${siteCfg.user} ${siteCfg.user}";
      sharedDirs = lib.unique (lib.concatMap withParents siteCfg.sharedDirs);
    in
    import ../../utils/release-dirs.nixos.nix { inherit siteCfg; }
    ++ map (dir: "d ${siteCfg.sharedDir}/${dir} 0750 ${owner} -") sharedDirs;
in
{
  imports = [
    (import ../../modules/users.nixos.nix {
      inherit sites;
    })
  ];

  options.services.ts1997.symfonySites = lib.mkOption {
    type = lib.types.attrsOf (
      util.submodule {
        imports = [
          ../options/app-options.base.nix
          ../options/app-options.nixos.nix
          ./options/symfony-options.nixos.nix
        ];
      }
    );
    default = { };
    description = "Symfony application configuration";
  };

  config = lib.mkIf (sites != { }) {
    assertions = lib.concatLists (
      lib.mapAttrsToList (name: siteCfg: [
        {
          assertion = !siteCfg.database.enable && !siteCfg.redis.enable;
          message = "services.ts1997.symfonySites.${name}: database/redis provisioning is not supported yet.";
        }
      ]) sites
    );

    systemd.tmpfiles.rules = lib.concatMap mkTmpfilesRules (lib.attrValues sites);

    system.activationScripts = lib.mkMerge (
      lib.mapAttrsToList (
        name: siteCfg:
        lib.mkIf (siteCfg.generateEnv) {
          "generate-env-${name}" = (
            import ../../utils/generate-env.nixos.nix {
              inherit lib pkgs siteCfg;
              defaultEnv = import ./config/default-env.nix { inherit lib siteCfg; };
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

    services.ts1997.restic.jobs = lib.mapAttrs (name: siteCfg: {
      inherit (siteCfg.backup) paths exclude;
    }) backupSites;
  };
}
