{
  config,
  lib,
  util,
  ...
}:
let
  cfg = config.services.ts1997.nginx;

  mkLocations =
    locations:
    lib.mapAttrs (
      name: location:
      location
      // {
        extraConfig = lib.concatStringsSep "\n" location.extraConfig;
      }
    ) locations;
in
{
  options.services.ts1997.nginx = lib.mkOption {
    type = util.submodule {
      imports = [
        ./options/nginx-options.common.nix
        ./options/nginx-options.nixos.nix
      ];
    };
    default = { };
    description = "Nginx web server configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    users = {
      users = lib.mkMerge (
        lib.mapAttrsToList (name: siteCfg: {
          ${siteCfg.user}.extraGroups = [ "nginx" ];
          nginx.extraGroups = [ siteCfg.user ];
        }) cfg.virtualHosts
      );

      groups = lib.mkMerge (
        lib.mapAttrsToList (name: siteCfg: {
          ${siteCfg.user} = {
            members = [
              "nginx"
            ];
          };
        }) cfg.virtualHosts
      );
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
        25
        465
      ];
    };

    services.nginx = {
      enable = cfg.enable;
      enableReload = true;
      logError = "stderr";
      package = cfg.fullPackage;

      virtualHosts = lib.mkMerge [
        (lib.mapAttrs (name: siteCfg: {
          enableACME = true;
          forceSSL = true;
          serverName = if siteCfg.forceWWW then "www.${siteCfg.serverName}" else siteCfg.serverName;
          serverAliases = siteCfg.serverAliases;
          root = siteCfg.root;
          extraConfig = lib.concatStringsSep "\n" siteCfg.extraConfig;
          locations = mkLocations (siteCfg.locations) // {
            "~ /\\.(?!well-known).*" = {
              extraConfig = "deny all;";
            };
          };
        }) cfg.virtualHosts)

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
          ) cfg.virtualHosts
        ))
      ];
    };
  };
}
