{
  config,
  lib,
  util,
  ...
}:
let
  cfg = config.services.ts1997.nginx;
in
{
  options.services.ts1997.nginx = lib.mkOption {
    type = util.submodule {
      imports = [
        ./options/nginx-options.base.nix
        ./options/nginx-options.devenv.nix
      ];
    };
    default = { };
    description = "Nginx web server configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    certificates = lib.flatten (
      lib.mapAttrsToList (
        vhostName: vhostCfg:
        lib.optionals (vhostCfg.enableSsl) ([ vhostCfg.serverName ] ++ vhostCfg.serverAliases)
      ) cfg.virtualHosts
    );

    hosts = builtins.listToAttrs (
      lib.flatten (
        lib.mapAttrsToList (
          vhostName: vhostCfg:
          map (domain: {
            name = domain;
            value = "127.0.0.1";
          }) ([ vhostCfg.serverName ] ++ vhostCfg.serverAliases)
        ) cfg.virtualHosts
      )
    );

    services.nginx = {
      enable = cfg.enable;
      package = cfg.fullPackage;

      httpConfig = lib.concatStringsSep "\n\n" (
        lib.mapAttrsToList (vhostName: vhostCfg: ''
          server {
            listen ${toString vhostCfg.port};
            ${lib.optionalString (vhostCfg.enableSsl) ''
              listen ${toString vhostCfg.sslPort} ssl;
              ssl_certificate ${vhostCfg.sslCert};
              ssl_certificate_key ${vhostCfg.sslKey};
            ''}

            server_name ${lib.concatStringsSep " " ([ vhostCfg.serverName ] ++ vhostCfg.serverAliases)};
            root ${vhostCfg.root};
            
            ${vhostCfg.extraConfig}

            ${lib.concatStringsSep "\n\n" (
              lib.mapAttrsToList (locationName: locationCfg: ''
                location ${locationName} {
                  ${lib.optionalString (locationCfg.alias != null) "alias ${locationCfg.alias};"}
                  ${lib.optionalString (locationCfg.proxyPass != null) "proxy_pass ${locationCfg.proxyPass};"}
                  ${lib.optionalString (locationCfg.return != null) "return ${toString locationCfg.return};"}
                  ${lib.optionalString (locationCfg.root != null) "root ${locationCfg.root};"}
                  ${lib.optionalString (locationCfg.tryFiles != null) "try_files ${locationCfg.tryFiles};"}

                  ${lib.concatStringsSep "\n" (
                    lib.mapAttrsToList (n: v: ''fastcgi_param ${n} "${v}";'') (
                      lib.optionalAttrs (locationCfg.fastcgiParams != { }) locationCfg.fastcgiParams
                    )
                  )}

                  ${lib.optionalString (locationCfg.basicAuthFile != null) (''
                    auth_basic secured;
                    auth_basic_user_file ${locationCfg.basicAuthFile};
                  '')}

                  ${locationCfg.extraConfig}
                }
              '') vhostCfg.locations
            )}
          }
        '') cfg.virtualHosts
      );
    };

    processes.nginx = {
      process-compose = {
        readiness_probe = {
          http_get = {
            host = (lib.head (lib.attrValues cfg.virtualHosts)).serverName;
            port = (lib.head (lib.attrValues cfg.virtualHosts)).port;
            path = "/";
          };
          initial_delay_seconds = 1;
          period_seconds = 1;
          timeout_seconds = 5;
          success_threshold = 1;
          failure_threshold = 30;
        };
      };
    };

    scripts.browse.exec = lib.concatStringsSep " & " (
      lib.mapAttrsToList (
        vhostName: vhostCfg:
        if (vhostCfg.enableSsl) then
          "open https://${vhostCfg.serverName}:${toString vhostCfg.sslPort}/"
        else
          "open http://${vhostCfg.serverName}:${toString vhostCfg.port}/"
      ) cfg.virtualHosts
    );
  };
}
