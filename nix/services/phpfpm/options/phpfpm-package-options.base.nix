{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    basePackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.php;
      description = "The PHP-FPM package to use.";
    };

    extensions = lib.mkOption {
      type = with lib.types; functionTo (listOf anything);
      default = extensions: [ ];
      description = "A list of PHP extensions to include.";
      example = lib.literalExpression "extensions: [ extensions.redis ]";
    };

    ini = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "php.ini directives baked into the package (also applies to the PHP CLI).";
    };

    fullPackage = lib.mkOption {
      type = lib.types.package;
      default = config.basePackage.buildEnv {
        extensions = { all, enabled }: enabled ++ (config.extensions all);
        extraConfig = config.ini;
      };
      readOnly = true;
      description = "The PHP-FPM package combined with the selected extensions.";
    };
  };
}
