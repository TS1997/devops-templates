{
  config,
  lib,
  name,
  ...
}:
{
  options = {
    enable = lib.mkEnableOption "this static site";

    domain = lib.mkOption {
      type = lib.types.str;
      example = "example.com";
      description = "Domain the site is served on.";
    };

    extraDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional domains served by the same virtual host.";
    };

    workingDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${name}";
      description = "Home directory of the site user, holding the deployed releases.";
    };

    releases.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Atomic deploys: static-deploy.yml uploads each build to
        `<workingDir>/releases/<id>` and switches the `<workingDir>/current`
        symlink to it. Until the first such deploy `current` points at
        `workingDir`. When disabled the build is uploaded into `workingDir`.
      '';
    };

    currentDir = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Directory holding the live build: `<workingDir>/current` with `releases.enable`, otherwise `workingDir`.";
    };

    sharedDir = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Directory holding data shared by all releases: `<workingDir>/shared` with `releases.enable`, otherwise `workingDir`.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "System user owning the site; the deploy workflow connects as this user.";
    };

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "SSH public keys allowed to deploy as the site user.";
    };

    forceWWW = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to force the www prefix for this virtual host.";
    };

    basicAuthFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/path/to/htpasswd";
      description = "Path to an htpasswd file to enable HTTP basic authentication for the site.";
    };
  };

  config = {
    currentDir = if config.releases.enable then "${config.workingDir}/current" else config.workingDir;
    sharedDir = if config.releases.enable then "${config.workingDir}/shared" else config.workingDir;
  };
}
