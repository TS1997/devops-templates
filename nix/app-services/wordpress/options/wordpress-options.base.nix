{
  lib,
  util,
  pkgs,
  ...
}:
{
  options = {
    tablePrefix = lib.mkOption { # Should be moved to database.<some-attr>
      type = lib.types.str;
      default = "wp_";
      description = "The WordPress database table prefix.";
    };

    multisite = lib.mkOption {
      type = util.submodule {
        options = {
          enable = lib.mkEnableOption "Enable WordPress Multisite.";

          subdomains = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to use subdomain-based multisite (true) or subdirectory-based (false).";
          };
        };
      };
      default = { };
      description = "WordPress Multisite configuration.";
    };

    assetFallbackUrls = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Name of the fallback location (e.g., @production, @staging)";
              example = "@production";
            };
            url = lib.mkOption {
              type = lib.types.str;
              description = "URL to fallback to when assets are not found locally";
              example = "https://www.example.com";
            };
            hosts = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = ''
                Restrict this fallback to specific request hosts (matched against
                the `Host` header, e.g. the site's `domain`/`extraDomains`).
                Only needed when a single virtual host serves multiple domains
                (via `extraDomains`) and each domain should fall back to a
                different upstream. Leave empty to use this entry as the
                default fallback for any host that doesn't match a more
                specific entry.
              '';
              example = [ "7hkraft.bravomedia.se" ];
            };
          };
        }
      );
      default = [ ];
      description = "Asset fallback URLs. A list of attribute sets with a name and url key.";
      example = [
        {
          name = "@production";
          url = "https://www.example.com";
        }
      ];
    };
  };

  config = {
    database.driver = lib.mkDefault "mysql";
    database.package = lib.mkDefault pkgs.mysql84;
  };
}
