{ config, lib, ... }:
let
  cfg = config.services.ts1997.laravel.sites;
in
{
  options.services.ts1997.laravel.sites = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }@args:
        {
          imports = [
            (import ./options/nixos-options.nix (args // { name = name; }))
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
