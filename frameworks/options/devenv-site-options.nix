{ lib, devenvRoot, ... }:
{
  imports = [ ./shared-site-options.nix ];

  options = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the site development environment.";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "The port on which the development environment will run.";
    };

    sslPort = lib.mkOption {
      type = lib.types.int;
      default = 5443;
      description = "The SSL port on which the development environment will run.";
    };

    enableSsl = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable SSL in the development environment.";
    };
  };
}
