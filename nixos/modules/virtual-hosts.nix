{
  config,
  pkgs,
  lib,
  options,
  ...
}:
let
  cfg = config.services.ts1997.virtualHosts;
in
{
  options.services.ts1997.virtualHosts = options.services.nginx.virtualHosts // {
    forceWWW = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to force www redirection.";
    };
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
          {
            enableACME = lib.mkDefault true;
            forceSSL = lib.mkDefault true;
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

            root = lib.mkDefault "/var/www/${name}";
          }
          // siteCfg
        ) cfg)

        # WWW redirects
        (lib.mapAttrs (
          name: siteCfg:
          lib.optionalAttrs siteCfg.forceWWW {
            "${name}-redirect" = {
              serverName = siteCfg.serverName;
              enableACME = true;
              forceSSL = true;
              locations."/".return = "301 https://www.${siteCfg.serverName}$request_uri";
            };
          }
        ) cfg)
      ];
    };
  };
}
