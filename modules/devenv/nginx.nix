{
  config,
  lib,
  options,
  ...
}:
let
  cfg = config.services.ts1997.nginx;

  mkDefaultExtraConfig = import ../settings/nginx-extra-config.nix;
in
{
  options.services.ts1997.nginx = options.services.nginx // {
    root = lib.mkOption {
      type = lib.types.str;
      default = "${config.env.DEVENV_ROOT}/public";
      description = "Default root directory for nginx.";
    };

    serverName = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      description = "Default server name for nginx.";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "Default port for nginx to listen on.";
    };

    sslPort = lib.mkOption {
      type = lib.types.int;
      default = 5443;
      description = "Default SSL port for nginx to listen on.";
    };

    enableSsl = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable SSL in nginx.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Additional global nginx configuration directives.";
    };

    locations = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            alias = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "NGINX alias directive for this location.";
              example = "/var/www/static/";
            };
            tryFiles = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "NGINX try_files directive for this location.";
              example = " $uri $uri/ /index.php?$query_string";
            };
            extraConfig = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "NGINX location block configuration";
              example = "proxy_pass http://backend;";
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
      SSL_CERT = "${config.env.DEVENV_STATE}/mkcert/${cfg.serverName}.pem";
      SSL_CERT_KEY = "${config.env.DEVENV_STATE}/mkcert/${cfg.serverName}-key.pem";
    };

    services.nginx = {
      enable = lib.mkDefault true;
      httpConfig = lib.mkDefault ''
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

          root ${cfg.root};
          server_name ${cfg.serverName};

          ${mkDefaultExtraConfig}
          ${cfg.extraConfig}

          ${lib.concatStringsSep "\n\n" (
            lib.mapAttrsToList (name: loc: ''
              location ${name} {
                ${lib.optionalString (loc.tryFiles != null) "try_files ${loc.tryFiles};"}
                ${lib.optionalString (loc.alias != null) "alias ${loc.alias};"}
                ${loc.extraConfig}
              }
            '') cfg.locations
          )}
        }
      '';
    };

    certificates = lib.mkIf (cfg.enableSsl) [ cfg.serverName ];
    hosts = {
      "${cfg.serverName}" = "127.0.0.1";
    };

    scripts = {
      browse.exec =
        if cfg.enableSsl then
          "open https://${cfg.serverName}:${toString cfg.sslPort}/"
        else
          "open http://${cfg.serverName}:${toString cfg.port}/";
    };
  };
}
