{
  lib,
  pkgs,
  ...
}:
{
  options = {
    enable = lib.mkEnableOption "Enable OpenSearch service.";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.opensearch;
      description = "The OpenSearch package to use.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 9200;
      description = "The HTTP port for OpenSearch.";
    };

    heapSize = lib.mkOption {
      type = lib.types.str;
      default = "512m";
      example = "1g";
      description = "JVM heap size (sets both -Xms and -Xmx).";
    };

    url = lib.mkOption {
      type = lib.types.str;
      description = "The HTTP URL OpenSearch is reachable on.";
      readOnly = true;
    };
  };
}
