{
  config,
  lib,
  util,
  ...
}:
let
  cfg = config.services.ts1997.nginx;
  vhostCfg = cfg.virtualHost;
in
{
  options.services.ts1997.nginx = lib.mkOption {
    type = util.submodule {
      imports = [
        ./options/nginx-options.nix
      ];

      options = {
        virtualHost = lib.mkOption {
          type = util.submodule {
            imports = [
              ./options/nginx-vhost-options.common.nix
              ./options/nginx-vhost-options.devenv.nix
            ];
          };
          default = { };
          description = "Virtual host configuration.";
        };
      };
    };
    default = { };
    description = "Nginx web server configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    certificates = lib.optionals (vhostCfg.enableSsl) [ vhostCfg.serverName ] ++ vhostCfg.serverAliases;

    hosts = builtins.listToAttrs (
      map (domain: {
        name = domain;
        value = "127.0.0.1";
      }) ([ vhostCfg.serverName ] ++ vhostCfg.serverAliases)
    );

    services.nginx = {
      enable = cfg.enable;
      package = cfg.fullPackage;

      httpConfig = ''
        server {
          listen ${toString vhostCfg.port};
          ${lib.optionalString (vhostCfg.enableSsl) ''
            listen ${toString vhostCfg.sslPort} ssl;
            ssl_certificate ${vhostCfg.sslCert};
            ssl_certificate_key ${vhostCfg.sslKey};
          ''}

          server_name ${lib.concatStringsSep " " ([ vhostCfg.serverName ] ++ vhostCfg.serverAliases)};
          root ${vhostCfg.root};
          
          ${lib.concatStringsSep "\n" vhostCfg.extraConfig}

          ${lib.concatStringsSep "\n\n" (
            lib.mapAttrsToList (name: location: ''
              location ${name} {
                ${lib.optionalString (location.alias != null) "alias ${location.alias};"}
                ${lib.optionalString (location.proxyPass != null) "proxy_pass ${location.proxyPass};"}
                ${lib.optionalString (location.return != null) "return ${toString location.return};"}
                ${lib.optionalString (location.root != null) "root ${location.root};"}
                ${lib.optionalString (location.tryFiles != null) "try_files ${location.tryFiles};"}

                ${lib.concatStringsSep "\n" (
                  lib.mapAttrsToList (n: v: ''fastcgi_param ${n} "${v}";'') (
                    lib.optionalAttrs (location.fastcgiParams != { }) location.fastcgiParams
                  )
                )}

                ${lib.optionalString (location.basicAuthFile != null) (''
                  auth_basic secured;
                  auth_basic_user_file ${location.basicAuthFile};
                '')}

                ${lib.concatStringsSep "\n" location.extraConfig}
              }
            '') vhostCfg.locations
          )}
        }
      '';
    };

    scripts.browse.exec =
      if (vhostCfg.enableSsl) then
        "open https://${vhostCfg.serverName}:${toString vhostCfg.sslPort}/"
      else
        "open http://${vhostCfg.serverName}:${toString vhostCfg.port}/";
  };
}
