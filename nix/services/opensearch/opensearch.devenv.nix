{
  config,
  lib,
  util,
  ...
}:
let
  cfg = config.services.ts1997.opensearch;
  httpPort = config.processes.opensearch.ports.http.value;
in
{
  options.services.ts1997.opensearch = lib.mkOption {
    type = util.submodule {
      imports = [
        ./options/opensearch-options.base.nix
      ];

      config.url = "http://127.0.0.1:${toString httpPort}";
    };
    default = { };
    description = "OpenSearch service configuration.";
  };

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
