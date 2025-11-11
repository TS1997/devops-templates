{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain name for the site.";
    };

    phpPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.php83;
      description = "The PHP package to use for this site.";
    };

    # Default is set in environment-specific options files
    workingDir = lib.mkOption {
      type = lib.types.str;
      description = "The working directory for the site.";
    };

    webRoot = lib.mkOption {
      type = lib.types.str;
      default = "${config.workingDir}/public";
      description = "The web root directory for the site.";
    };
  };
}
