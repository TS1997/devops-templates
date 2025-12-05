{ lib, util, ... }:
{
  imports = [ ./phpfpm-package-options.base.nix ];

  options = {
    enable = lib.mkEnableOption "Enable PHP-FPM service.";

    extraConfig = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      description = "Global PHP-FPM configuration.";
    };

    pools = lib.mkOption {
      type = lib.types.attrsOf (
        util.submodule {
          imports = [ ./phpfpm-pool-options.base.nix ];
        }
      );
      description = "A set of PHP-FPM pools to configure.";
      default = { };
    };
  };
}
