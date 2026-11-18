{
  config,
  lib,
  util,
  ...
}:
let
  sites = lib.filterAttrs (_: siteCfg: siteCfg.enable) config.services.ts1997.staticSites;

  mkTmpfilesRules =
    siteCfg:
    let
      owner = "${siteCfg.user} ${siteCfg.user}";
    in
    [
      "d ${siteCfg.workingDir} 0750 ${owner} -"
      # Re-own everything on boot and on every switch, leaving modes untouched.
      "Z ${siteCfg.workingDir} - ${owner} -"
    ]
    ++ import ../../utils/release-dirs.nixos.nix { inherit siteCfg; };
in
{
  imports = [
    (import ../../modules/users.nixos.nix {
      inherit sites;
    })
  ];

  options.services.ts1997.staticSites = lib.mkOption {
    type = lib.types.attrsOf (
      util.submodule {
        imports = [ ./options/static-options.nixos.nix ];
      }
    );
    default = { };
    description = "Static sites, built in CI and deployed with static-deploy.yml.";
  };

  config = lib.mkIf (sites != { }) {
    systemd.tmpfiles.rules = lib.concatMap mkTmpfilesRules (lib.attrValues sites);

    services.ts1997.nginx = {
      enable = true;
      virtualHosts = lib.mapAttrs (name: siteCfg: {
        serverName = siteCfg.domain;
        serverAliases = siteCfg.extraDomains;
        root = siteCfg.currentDir;
        forceWWW = siteCfg.forceWWW;
        basicAuthFile = siteCfg.basicAuthFile;
        user = siteCfg.user;
        locations = {
          "/" = {
            tryFiles = "$uri $uri/ =404";
            extraConfig = "error_page 404 /404.html;";
          };
          # Astro's content-hashed build output. `expires` instead of
          # add_header keeps the server-level headers.
          "/_astro/" = {
            extraConfig = "expires 1y;";
          };
        };
      }) sites;
    };
  };
}
