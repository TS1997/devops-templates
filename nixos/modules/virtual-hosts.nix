{
  config,
  pkgs,
  lib,
  options,
  ...
}:
let
  cfg = config.services.ts1997.virtualHosts;

  # Filter out custom options that nginx doesn't know about
  filterCustomOptions =
    siteCfg:
    builtins.removeAttrs siteCfg [
      "forceWWW"
      "_module"
    ];
in
{
  options.services.ts1997.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, name, ... }:
        {
          imports = options.services.nginx.virtualHosts.type.getSubModules;

          options = {
            forceWWW = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to force www redirection for this virtual host.";
            };
          };
        }
      )
    );
    default = { };
    description = "Extended nginx virtual hosts with TS1997 defaults.";
  };

  config = lib.mkIf (cfg != { }) {
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

            extraConfig = ''
              index index.html index.htm index.php;
              add_header X-Frame-Options "SAMEORIGIN";
              add_header X-Content-Type-Options "nosniff";
              charset utf-8;

              ${siteCfg.extraConfig or ""}
            '';

            locations = (siteCfg.locations or { }) // {
              "~ /\\.(?!well-known).*" = {
                extraConfig = "deny all;";
              };
            };
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
