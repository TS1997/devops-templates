{ lib, util, ... }:
{
  options = {
    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "The port that the application will be served on.";
    };

    sslPort = lib.mkOption {
      type = lib.types.int;
      default = 5443;
      description = "The SSL port that the application will be served on.";
    };

    enableSsl = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable SSL for the application.";
    };
  };

  config = {
    workingDir = lib.mkDefault util.values.devenvRoot;
  };
}
