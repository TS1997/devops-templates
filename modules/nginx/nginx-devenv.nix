{
  config,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.nginx;

  serverNames = [ cfg.serverName ] ++ cfg.serverAliases;
  serverName = cfg.serverName + (lib.concatStringsSep " " cfg.serverAliases);
  numberOfServerAliases = builtins.length cfg.serverAliases;
  certificateName =
    if numberOfServerAliases > 0 then
      "${cfg.serverName}+${toString numberOfServerAliases}"
    else
      cfg.serverName;

  defaultExtraConfig = import ./config/extra-config.nix;
in
{
  options.services.ts1997.nginx = lib.mkOption {
    type = lib.types.submodule {
      imports = [
        (import ./nginx-options.nix { inherit lib; })
      ];

      options = {
        port = lib.mkOption {
          type = lib.types.int;
          default = 8080;
          description = "The port that nginx will listen on.";
        };

        sslPort = lib.mkOption {
          type = lib.types.int;
          default = 5443;
          description = "The port that nginx will listen on for SSL.";
        };

        enableSsl = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable SSL for the nginx instance.";
        };
      };
    };
    description = "Nginx service configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    env = {
      SSL_CERT = "${config.env.DEVENV_STATE}/mkcert/${certificateName}.pem";
      SSL_CERT_KEY = "${config.env.DEVENV_STATE}/mkcert/${certificateName}-key.pem";
    };

    services.nginx = {
      enable = cfg.enable;
      httpConfig = ''
        server {
          listen ${toString cfg.port};
          ${
            if cfg.enableSsl then
              ''
                listen ${toString cfg.sslPort} ssl;
                ssl_certificate ${config.env.SSL_CERT};
                ssl_certificate_key ${config.env.SSL_CERT_KEY};
              ''
            else
              ""
          }

          server_name ${serverName};
          root ${cfg.root};

          ${defaultExtraConfig + cfg.extraConfig}

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
            '') cfg.locations
          )}
        }
      '';
    };

    certificates = lib.mkIf (cfg.enableSsl) serverNames;

    hosts = builtins.listToAttrs (
      map (domain: {
        name = domain;
        value = "127.0.0.1";
      }) serverNames
    );

    scripts = {
      browse.exec =
        if cfg.enableSsl then
          "open https://${cfg.serverName}:${toString cfg.sslPort}/"
        else
          "open http://${cfg.serverName}:${toString cfg.port}/";
    };
  };
}
