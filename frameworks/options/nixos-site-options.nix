{ config, lib, ... }:
{
  imports = [ ./shared-site-options.nix ];

  options = {
    user = lib.mkOption {
      type = lib.types.str;
      description = "The system user for the Laravel application.";
    };

    forceWWW = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to force www redirection.";
    };
  };

  config = {
    workingDir = lib.mkDefault "/var/lib/${config.user}";
  };
}
