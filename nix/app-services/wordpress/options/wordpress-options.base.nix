{ lib, util, pkgs, ... }:
{
  options = {
    tablePrefix = lib.mkOption {
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
    database.package = lib.mkDefault pkgs.mysql84;
  };
}
