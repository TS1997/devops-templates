{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.laravel.sites;
in
{
  options.services.ts1997.laravel.sites = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, config, ... }:
        {
          imports = [ ./options/nixos.nix ];

          config = {
            _module.args = {
              inherit pkgs lib;
            };
          };
        }
      )
    );
    default = { };
    description = "Laravel site configurations.";
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
            extraGroups = [ "nginx" ];
            packages = [ siteCfg.phpPackage ];
          };
          nginx.extraGroups = [ siteCfg.user ];
        }) cfg
      );

      groups = lib.mkMerge (
        lib.mapAttrsToList (name: siteCfg: {
          ${siteCfg.user} = {
            members = [
              siteCfg.user
              "nginx"
            ];
          };
        }) cfg
      );
    };

    services.ts1997.virtualHosts = lib.mapAttrs (name: siteCfg: {
      root = siteCfg.webRoot;
      serverName = siteCfg.domain;
      forceWWW = siteCfg.forceWWW;

      locations = {
        "/" = {
          tryFiles = "$uri $uri/ /index.php?$query_string";
        };

        "~ \\.php$" = {
          extraConfig = ''
            fastcgi_pass unix:${config.services.phpfpm.pools.${siteCfg.user}.socket};
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_index index.php;
            fastcgi_hide_header X-Powered-By;
            include ${pkgs.nginx}/conf/fastcgi_params;
          '';
        };

        "~ ^/livewire/" = {
          extraConfig = ''
            expires off;
            try_files $uri $uri/ /index.php?$query_string;
          '';
        };

        "/storage/" = {
          alias = "${siteCfg.workingDir}/storage/app/public/";
          extraConfig = ''
            expires 1y;
          '';
        };
      };
    }) cfg;

    services.ts1997.phpPools = lib.mapAttrs (name: siteCfg: {
      user = siteCfg.user;
      phpPackage = siteCfg.phpPackage;
    }) cfg;
  };
}
