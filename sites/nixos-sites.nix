{
  config,
  lib,
  ...
}:

let
  siteTypes = {
    laravel = ./modules/laravel/laravel-nixos.nix;
  };

  siteOptions = import ./site-options.nix;
in
{
  options.services.ts1997.sites = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, name, ... }:
        let
          modulePath = siteTypes.${config.type} or throw "Unknown site type: ${config.type}";
        in
        {
          imports = [ modulePath ];

          options = siteOptions // {
            type = lib.mkOption {
              type = lib.types.enum (lib.attrNames siteTypes);
              description = "The type of the site.";
            };
          };

          config = {
            specialArgs = {
              siteName = name;
            };
          };
        }
      )
    );
    default = { };
    description = "Website definitions";
  };

  config = lib.mkIf (config.services.ts1997.sites != { }) {
    users.groups = lib.mkMerge (
      lib.mapAttrsToList (_: siteCfg: {
        "${siteCfg.user}".members = [ siteCfg.user ];
      }) config.services.ts1997.sites
    );

    users.users = lib.mkMerge (
      lib.mapAttrsToList (_: siteCfg: {
        "${siteCfg.user}" = {
          isSystemUser = true;
          createHome = true;
          home = siteCfg.workingDir;
          group = siteCfg.user;
        };
      }) config.services.ts1997.sites
    );
  };
}
