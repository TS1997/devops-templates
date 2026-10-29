{ lib, pkgs, ... }:
{
  options = {
    enable = lib.mkEnableOption "Enable Node.js development tooling.";

    install.enable = lib.mkEnableOption "Enable automatic installation of Node.js dependencies.";

    auth.enable = lib.mkEnableOption "Export the shared npm registry token (bravo_npm_token in devops-templates secrets) as BRAVO_NPM_TOKEN, for use in .npmrc.";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nodejs_24;
      description = "The Node.js package to use.";
    };

    script = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The npm script to run for the development server.";
    };
  };
}
