{ config, lib, ... }:
let
  sites = config.services.ts1997.sites;

  siteModules = {
    laravel = ./modules/laravel/laravel-nixos.nix;
  };
in
{
  options.services.ts1997.sites = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, name, ... }:
        {
          imports = [ ./site-options.nix ];

          options = {
            moduleName = lib.mkOption {
              type = lib.types.enum (lib.attrNames siteModules);
              description = "The site module to use for ${name}.";
            };
          };
        }
      )
    );
    default = { };
    description = "NixOS Site Configurations";
  };

  config = lib.mkIf (sites != { }) {
    users = {
      users = lib.mkMerge (
        lib.mapAttrsToList (name: siteCfg: {
          ${siteCfg.user} = {
            isSystemUser = true;
            createHome = true;
            home = siteCfg.workingDir;
            group = siteCfg.user;
          };
        }) sites
      );

      groups = lib.mkMerge (
        lib.mapAttrsToList (name: siteCfg: {
          ${siteCfg.user} = {
            members = [
              siteCfg.user
            ];
          };
        }) sites
      );
    };
  };
}
