{
  config,
  lib,
  util,
  ...
}:
let
  siteCfg = config.services.ts1997.staticSite;
in
{
  options.services.ts1997.staticSite = lib.mkOption {
    type = util.submodule {
      imports = [ ../options/app-hosts.devenv.nix ];

      options = {
        enable = lib.mkEnableOption "a static site built with npm and deployed with static-deploy.yml";

        nodejs = lib.mkOption {
          type = util.submodule {
            imports = [ ../../services/nodejs/options/nodejs-options.devenv.nix ];

            config = {
              enable = lib.mkDefault true;
              install.enable = lib.mkDefault true;
              script = lib.mkDefault "npm run dev";
            };
          };
          default = { };
          description = "Node.js configuration for the site.";
        };
      };
    };
    default = { };
    description = "Static site configuration.";
  };

  config = lib.mkIf siteCfg.enable {
    services.ts1997.nodejs = siteCfg.nodejs;

    processes = lib.mkIf (siteCfg.nodejs.enable && siteCfg.nodejs.script != null) {
      nodejs.exec = siteCfg.nodejs.script;
    };
  };
}
