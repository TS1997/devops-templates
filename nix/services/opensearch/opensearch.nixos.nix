{
  config,
  lib,
  util,
  ...
}:
let
  cfg = config.services.ts1997.opensearch;
in
{
  options.services.ts1997.opensearch = lib.mkOption {
    type = util.submodule {
      imports = [
        ./options/opensearch-options.base.nix
        ({ config, ... }: { config.url = "http://127.0.0.1:${toString config.port}"; })
      ];
    };
    default = { };
    description = "OpenSearch service configuration.";
  };

  # Single node bound to 127.0.0.1 with the security plugin disabled (nixpkgs defaults).
  # Shared by all sites on the host, so sites must use unique index prefixes.
  config = lib.mkIf (cfg.enable) {
    services.opensearch = {
      enable = cfg.enable;
      package = cfg.package;
      settings."http.port" = cfg.port;
      extraJavaOptions = [
        "-Xms${cfg.heapSize}"
        "-Xmx${cfg.heapSize}"
      ];
    };
  };
}
