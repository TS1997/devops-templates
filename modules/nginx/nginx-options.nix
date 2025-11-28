{ lib, ... }:
{
  options = {
    enable = lib.mkEnableOption "Enable the Nginx service.";

    serverName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Name of this virtual host. Defaults to attribute name in virtualHosts.";
      example = "example.com";
    };

    serverAliases = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "www.example.com"
        "example.com"
      ];
      description = "Additional names of virtual hosts served by this virtual host configuration.";
    };

    root = lib.mkOption {
      type = lib.types.path;
      description = "The root directory for the nginx instance.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "These lines go to the end of the vhost verbatim.";
    };

    locations = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            alias = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              example = "/your/alias/directory";
              description = "Alias directory for requests.";
            };
            basicAuthFile = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              example = "/path/to/htpasswd";
              description = "Path to the htpasswd file for basic authentication.";
            };
            extraConfig = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "These lines go to the end of the location verbatim.";
            };
            fastcgiParams = lib.mkOption {
              type = lib.types.attrsOf (
                lib.types.oneOf [
                  lib.types.str
                  lib.types.path
                ]
              );
              default = { };
              description = "FastCGI parameters for this location.";
            };
            proxyPass = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              example = "http://www.example.com";
              description = "Proxy pass URL for this location.";
            };
            return = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              example = "301 https://$host$request_uri";
              description = "Return directive for this location.";
            };
            root = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              example = "/your/root/directory";
              description = "Root directory for this location.";
            };
            tryFiles = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              example = "$uri =404";
              description = "Adds try_files directive.";
            };
          };
        }
      );
      description = "NGINX location blocks";
      default = { };
    };
  };
}
