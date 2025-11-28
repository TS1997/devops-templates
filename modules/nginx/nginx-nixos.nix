{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.virtualHosts;

  defaultExtraConfig = import ./config/extra-config.nix;
in
{
  options.services.ts1997.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, config, ... }:
        {
          imports = [
            (import ./nginx-options.nix { inherit lib; })
          ];

          options = {
            forceWWW = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to force www redirection for this virtual host.";
            };

            user = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "The user that nginx will run as for this virtual host.";
            };
          };

          config = {
            enable = lib.mkDefault true;
            root = lib.mkDefault "/var/lib/${name}/public";
          };
        }
      )
    );
    default = { };
    description = "Nginx virtual hosts configuration.";
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
        (lib.mapAttrs (name: siteCfg: {
          enableACME = true;
          forceSSL = true;
          serverName = if siteCfg.forceWWW then "www.${siteCfg.serverName}" else siteCfg.serverName;
          serverAliases = siteCfg.serverAliases;
          root = siteCfg.root;
          extraConfig = defaultExtraConfig + siteCfg.extraConfig;
          locations = siteCfg.locations // {
            "~ /\\.(?!well-known).*" = {
              extraConfig = "deny all;";
            };
          };
        }) cfg)

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
