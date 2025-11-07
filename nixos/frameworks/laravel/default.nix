{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.laravel;
  mkSetFilePermissions = import ./scripts/file-permissions.nix { inherit pkgs; };
  mkDeploy = import ./scripts/deploy.nix { inherit pkgs lib; };
in
{
  options.services.ts1997.laravel = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, name, ... }:
        {
          options = {
            forceWWW = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to force www redirection for Laravel sites.";
            };

            user = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "The system user to run the Laravel instance under.";
            };

            workingDir = lib.mkOption {
              type = lib.types.str;
              default = "/var/lib/${name}";
              description = "The working directory of the Laravel application.";
            };

            webRoot = lib.mkOption {
              type = lib.types.str;
              default = "${config.workingDir}/public";
              description = "The web root directory of the Laravel application.";
            };

            phpPackage = lib.mkOption {
              type = lib.types.package;
              default = pkgs.php83;
              description = "The PHP package to use for the Laravel application.";
            };

            extraEnvs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "List of extra environment variables to set in the .env file.";
            };

            postDeployCommands = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "List of shell commands to run after deployment.";
            };
          };
        }
      )
    );
    default = { };
    description = "List of Laravel instances to enable.";
  };

  config = lib.mkIf (cfg != { }) {
    system.activationScripts = lib.mkMerge (
      lib.mapAttrs (name: siteCfg: {
        "laravel-setup-${name}" = lib.stringAfter [ "users" "groups" "agenix" ] ''
          ${mkSetFilePermissions name siteCfg}
        '';
      }) cfg
    );

    environment.systemPackages = lib.flatten [
      (lib.mapAttrsToList (name: siteCfg: mkDeploy name siteCfg) cfg)
    ];

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
            isSystemGroup = true;
            members = [
              siteCfg.user
              "nginx"
            ];
          };
        }) cfg
      );
    };

    services.ts1997.virtualHosts = lib.mapAttrs (name: siteCfg: {
      forceWWW = lib.mkDefault true;
      root = lib.mkDefault siteCfg.webRoot;

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
          alias = "${siteCfg.webRoot}/storage/";
          extraConfig = ''
            expires 1y;
          '';
        };
      };
    }) cfg;

    services.ts1997.php = lib.mapAttrs (name: siteCfg: {
      user = siteCfg.user;
      phpPackage = siteCfg.phpPackage;
    }) cfg;

    services.ts1997.mysql = lib.mapAttrs (name: siteCfg: {
      user = siteCfg.user;
      dbName = name;
    }) cfg;

    services.ts1997.redis = lib.mapAttrs (name: siteCfg: {
      user = siteCfg.user;
      group = siteCfg.user;
    }) cfg;
  };
}
