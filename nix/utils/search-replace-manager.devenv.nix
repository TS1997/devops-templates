{
  config,
  lib,
  pkgs,
  ...
}:
let
  searchReplaceManager = import ../lib/search-replace-manager.nix { inherit pkgs lib; };
in
{
  options.services.ts1997.searchReplace = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options.from = lib.mkOption {
          type = lib.types.str;
          example = "production";
          description = "Environment whose home URL is read (never written to).";
        };
        options.fromUrl = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "https://example.se";
          description = "URL to replace, instead of reading the `from` environment's home URL.";
        };
      }
    );
    default = { };
    example = {
      dev.from = "staging";
    };
  };

  config = lib.mkIf config.services.ts1997.wordpressSite.enable {
    services.ts1997.searchReplace.staging.from = lib.mkDefault "production";

    packages = lib.mapAttrsToList (
      targetEnvironment: searchReplace:
      searchReplaceManager.mkSearchReplace {
        devenvRoot = config.devenv.root;
        hostsAttr = "services.ts1997.wordpressSite.hosts";
        sourceEnvironment = searchReplace.from;
        sourceUrl = searchReplace.fromUrl;
        inherit targetEnvironment;
      }
    ) config.services.ts1997.searchReplace;
  };
}
