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
      type = lib.types.listOf lib.types.package;
      default = with pkgs.nginxModules; [ cache-purge ];
      description = "A list of nginx modules to include.";
    };

    fullPackage = lib.mkOption {
      type = lib.types.package;
      default = config.basePackage.override {
        modules = config.modules;
      };
      readOnly = true;
      description = "The nginx package combined with the selected modules.";
    };

    virtualHosts = lib.mkOption {
      type = lib.types.attrsOf (
        util.submodule {
          imports = [
            ./nginx-vhost-options.common.nix
          ];
        }
      );
      default = { };
      description = "A set of virtual hosts to configure.";
    };
  };
}
