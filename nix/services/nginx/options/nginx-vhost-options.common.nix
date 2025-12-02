{ lib, ... }:
{
  options = {
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
      type = lib.types.listOf (lib.types.lines);
      default = [
        ''
          index index.html index.htm index.php;
          add_header X-Frame-Options "SAMEORIGIN";
          add_header X-Content-Type-Options "nosniff";
          charset utf-8;
        ''
      ];
      description = "These lines go to the end of the vhost verbatim.";
    };

    locations = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          imports = [ ./nginx-location-options.nix ];
        }
      );
      description = "Nginx location blocks";
      default = { };
    };
  };
}
