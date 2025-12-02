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
        ./options/nginx-options.nix
      ];

      options = {
        # This extends the common nginx virtual host options with devenv-specific ones
        virtualHosts = lib.mkOption {
          type = lib.types.attrsOf (
            util.submodule {
              imports = [
                ./options/nginx-vhost-options.devenv.nix
              ];
            }
          );
          default = { };
          description = "A set of virtual hosts to configure.";
        };
      };
    };
    default = { };
    description = "Nginx web server configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    hosts = builtins.listToAttrs (
      map
        (domain: {
          name = domain;
          value = "127.0.0.1";
        })
        (
          lib.unique (
            lib.concatMap (vhostCfg: [ vhostCfg.serverName ] ++ vhostCfg.serverAliases) (
              lib.attrValues cfg.virtualHosts
            )
          )
        )
    );

    certificates = lib.mkMerge (
      lib.mapAttrsToList (
        name: vhostCfg:
        lib.mkIf vhostCfg.enableSsl [
          vhostCfg.serverName
        ]
        ++ vhostCfg.serverAliases
      ) cfg.virtualHosts
    );

    services.nginx = {
      enable = cfg.enable;
      package = cfg.fullPackage;

      httpConfig = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          name: vhostCfg: ''
            server {
              listen ${toString vhostCfg.port};
              ${lib.optionalString (vhostCfg.enableSsl) ''
                listen ${toString vhostCfg.sslPort} ssl;
                ssl_certificate ${vhostCfg.sslCert};
                ssl_certificate_key ${vhostCfg.sslKey};
              ''}

              server_name ${
                lib.concatStringsSep " " (lib.flattenList ([ vhostCfg.serverName ] ++ vhostCfg.serverAliases))
              };
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

                    ${location.extraConfig}
                  }
                '') vhostCfg.locations
              )}
            }
          ''
        )
      );
    };

    scripts.browse.exec =
      if cfg.enableSsl then
        "open https://${cfg.serverName}:${toString cfg.sslPort}/"
      else
        "open http://${cfg.serverName}:${toString cfg.port}/";
  };
}
