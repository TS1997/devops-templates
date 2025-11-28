{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    enable = lib.mkEnableOption "Enable the PHP-FPM service.";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.php;
      description = "The PHP package to use for the PHP-FPM service.";
    };

    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "A list of PHP extensions to enable.";
    };

    packageWithExtensions = lib.mkOption {
      type = lib.types.package;
      default = config.package.buildEnv {
        extensions = { all, enabled }: enabled ++ config.extensions;
      };
      description = "The PHP package with the specified extensions enabled.";
      readOnly = true;
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Additional PHP-FPM pool settings.";
    };

    phpOptions = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Additional PHP options for the PHP-FPM pool.";
    };
  };
}
