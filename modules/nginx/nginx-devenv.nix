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
  options.services.ts1997.nginx = {
    enable = lib.mkEnableOption "Enable the NGINX service.";

    serverName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Name of this virtual host. Defaults to attribute name in virtualHosts.
      '';
      example = "example.org";
    };

    serverAliases = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "www.example.org"
        "example.org"
      ];
      description = ''
        Additional names of virtual hosts served by this virtual host configuration.
      '';
    };

    root = lib.mkOption {
      type = lib.types.path;
      description = "The root directory for the nginx instance.";
    };

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

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        These lines go to the end of the vhost verbatim.
      '';
    };

    locations = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            alias = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              example = "/your/alias/directory";
              description = ''
                Alias directory for requests.
              '';
            };
            tryFiles = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              example = "$uri =404";
              description = ''
                Adds try_files directive.
              '';
            };
            extraConfig = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = ''
                These lines go to the end of the location verbatim.
              '';
            };
          };
        }
      );
      description = "NGINX location blocks";
      default = { };
    };
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
                ${lib.optionalString (location.tryFiles != null) "try_files ${location.tryFiles};"}
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
