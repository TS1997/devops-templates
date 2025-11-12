{
  config,
  pkgs,
  lib,
  options,
  ...
}:
let
  cfg = config.services.ts1997.virtualHosts;

  defaultExtraConfig = import ./settings/extra-config.nix;

  # Filter out custom options that nginx doesn't know about
  filterCustomOptions =
    siteCfg:
    builtins.removeAttrs siteCfg [
      "forceWWW"
      "user"
      "_module"
    ];
in
{
  options.services.ts1997.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, config, ... }:
        {
          imports = options.services.nginx.virtualHosts.type.getSubModules;

          options = {
            forceWWW = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to force www redirection for this virtual host.";
            };

            user = lib.mkOption {
              type = lib.types.str;
              default = "nginx";
              description = "The user that the PHP-FPM pool will run as.";
            };
          };
        }
      )
    );
    default = { };
    description = "Extended nginx virtual hosts configurations.";
  };

  config = lib.mkIf (cfg != { }) {
    users = {
      users = lib.mkMerge (
        lib.mapAttrsToList (name: siteCfg: {
          ${siteCfg.user}.extraGroups = [ "nginx" ];
          nginx.extraGroups = [ siteCfg.user ];
        }) cfg
      );

      groups = lib.mkMerge (
        lib.mapAttrsToList (name: siteCfg: {
          ${siteCfg.user} = {
            members = [
              "nginx"
            ];
          };
        }) cfg
      );
    };

    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = [
      80
      443
      25
      465
    ];

    services.nginx = {
      enable = true;
      enableReload = true;
      logError = "stderr";
      package = pkgs.nginx.override {
        modules = [ pkgs.nginxModules.cache-purge ];
      };

      virtualHosts = lib.mkMerge [
        (lib.mapAttrs (
          name: siteCfg:
          (filterCustomOptions siteCfg)
          // {
            enableACME = lib.mkDefault true;
            forceSSL = lib.mkDefault true;
            root = lib.mkDefault "/var/lib/${name}/public";
            serverName = if siteCfg.forceWWW then "www.${siteCfg.serverName}" else siteCfg.serverName;

            extraConfig = defaultExtraConfig + siteCfg.extraConfig;

            locations = {
              "~ /\\.(?!well-known).*" = {
                extraConfig = "deny all;";
              };
            }
            // (siteCfg.locations or { });
          }
        ) cfg)

        # WWW redirects
        (lib.mkMerge (
          lib.mapAttrsToList (
            name: siteCfg:
            lib.optionalAttrs siteCfg.forceWWW {
              "${name}-redirect" = {
                serverName = siteCfg.serverName;
                enableACME = true;
                forceSSL = true;
                locations."/".return = "301 https://www.${siteCfg.serverName}$request_uri";
              };
            }
          ) cfg
        ))
      ];
    };
  };
}
