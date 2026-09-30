{
  config,
  lib,
  util,
  ...
}:
let
  cfg = config.services.ts1997.nginx;
  httpPort = vhostName: toString config.processes.nginx.ports."${vhostName}-http".value;
  httpsPort = vhostName: toString config.processes.nginx.ports."${vhostName}-https".value;
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
            listen ${httpPort vhostName};
            ${lib.optionalString (vhostCfg.enableSsl) ''
              listen ${httpsPort vhostName} ssl;
              ssl_certificate ${vhostCfg.sslCert};
              ssl_certificate_key ${vhostCfg.sslKey};
            ''}

            server_name ${lib.concatStringsSep " " ([ vhostCfg.serverName ] ++ vhostCfg.serverAliases)};
            root ${vhostCfg.root};
            
            ${vhostCfg.extraConfig}

            location /healthcheck {
              access_log off;
              add_header Content-Type text/plain;
              return 200 'OK';
            }

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
      ports = lib.concatMapAttrs (
        vhostName: vhostCfg:
        {
          "${vhostName}-http".allocate = vhostCfg.port;
        }
        // lib.optionalAttrs vhostCfg.enableSsl { "${vhostName}-https".allocate = vhostCfg.sslPort; }
      ) cfg.virtualHosts;

      ready = {
        http.get = {
          host = (lib.head (lib.attrValues cfg.virtualHosts)).serverName;
          port = config.processes.nginx.ports."${lib.head (lib.attrNames cfg.virtualHosts)}-http".value;
          path = "/healthcheck";
        };
        initial_delay = 1;
        period = 10;
        probe_timeout = 5;
        success_threshold = 1;
        failure_threshold = 30;
      };
    };

    scripts.browse.exec = lib.concatStringsSep " & " (
      lib.mapAttrsToList (
        vhostName: vhostCfg:
        let
          url =
            if (vhostCfg.enableSsl) then
              "https://${vhostCfg.serverName}:${httpsPort vhostName}/"
            else
              "http://${vhostCfg.serverName}:${httpPort vhostName}/";
        in
        "xdg-open ${url} || open ${url}"
      ) cfg.virtualHosts
    );
  };
}
