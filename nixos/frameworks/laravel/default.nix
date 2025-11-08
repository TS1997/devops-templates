{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.laravelSites;
  mkDeploy = import ./scripts/deploy.nix {
    inherit pkgs lib;
  };
in
{
  options.services.ts1997.laravelSites = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, name, ... }:
        let
          baseEnv = import ./settings/base-env.nix {
            inherit name;
            siteCfg = config;
          };
        in
        {
          imports = [ ../options/site-options.nix ];

          config = {
            _module.args = {
              inherit pkgs lib;
            };

            # Merge base environment with user-defined environment variables
            environment = lib.mapAttrs (_: lib.mkDefault) baseEnv;
          };

          options = {
            postDeployCommands = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "List of shell commands to run after deploying the application.";
            };
          };
        }
      )
    );
    default = { };
    description = "Configuration options for Laravel sites.";
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

    environment.systemPackages = lib.flatten [
      (lib.mapAttrsToList (name: siteCfg: mkDeploy name siteCfg) cfg)
    ];

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

    services.ts1997.mysql = lib.mkMerge (
      lib.mapAttrsToList (
        name: siteCfg:
        lib.mkIf (siteCfg.database.enable && siteCfg.database.connection == "mysql") {
          ${name} = {
            dbUser = siteCfg.database.user;
            dbName = siteCfg.database.name;
          };
        }
      ) cfg
    );

    services.ts1997.pgsql = lib.mkMerge (
      lib.mapAttrsToList (
        name: siteCfg:
        lib.mkIf (siteCfg.database.enable && siteCfg.database.connection == "pgsql") {
          ${name} = {
            dbUser = siteCfg.database.user;
            dbName = siteCfg.database.name;
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
            unixSocket = siteCfg.redis.socket;
          };
        }
      ) cfg
    );
  };
}
