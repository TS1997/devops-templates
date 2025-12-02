{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    enable = lib.mkEnableOption "Enable nginx web server.";

    basePackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nginxStable;
      description = "The nginx package to use.";
    };

    modules = lib.mkOption {
      type = with lib.types; functionTo (listOf anything);
      default = modules: [ modules.cache-purge ];
      description = "A list of nginx modules to include.";
      example = lib.literalExpression "modules: [ modules.cache-purge ]";
    };

    fullPackage = lib.mkOption {
      type = lib.types.package;
      default = config.basePackage.override {
        modules = config.modules (pkgs.nginxModules);
      };
      readOnly = true;
      description = "The nginx package combined with the selected modules.";
    };
  };
}
