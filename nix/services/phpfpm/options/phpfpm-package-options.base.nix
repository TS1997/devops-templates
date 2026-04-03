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
      default = pkgs.php84;
      description = "The PHP-FPM package to use.";
    };

    extensions = lib.mkOption {
      type = with lib.types; functionTo (listOf anything);
      default = extensions: [ ];
      description = "A list of PHP extensions to include.";
      example = lib.literalExpression "extensions: [ extensions.redis ]";
    };

    fullPackage = lib.mkOption {
      type = lib.types.package;
      default = config.basePackage.buildEnv {
        extensions = { all, enabled }: enabled ++ (config.extensions all);
      };
      readOnly = true;
      description = "The PHP-FPM package combined with the selected extensions.";
    };
  };
}
