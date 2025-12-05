{
  config,
  lib,
  pkgs,
  util,
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

    virtualHosts = lib.mkOption {
      type = lib.types.attrsOf (
        util.submodule {
          imports = [
            ./nginx-vhost-options.base.nix
          ];
        }
      );
      default = { };
      description = "A set of virtual hosts to configure.";
    };
  };
}
