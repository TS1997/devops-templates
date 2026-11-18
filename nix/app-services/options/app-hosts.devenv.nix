{ lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  options.hosts = mkOption {
    type = types.attrsOf (
      types.submodule (
        { config, ... }:
        {
          options = {
            host = mkOption {
              type = types.str;
              description = "DNS name or IP of the server.";
            };
            siteName = mkOption {
              type = types.str;
              description = "Name of the site on the server; backups are pulled with its `restic-<siteName>` command and fresh database dumps with `db-dump-<siteName>`.";
            };
            user = mkOption {
              type = types.str;
              default = config.siteName;
              defaultText = lib.literalExpression "siteName";
              description = "SSH user the deploy workflows deploy as. The server creates the site's user with the site name unless overridden there.";
            };
          };
        }
      )
    );
    default = { };
    example = {
      production = {
        host = "example.com";
        siteName = "example";
      };
      staging = {
        host = "stage.example.com";
        siteName = "example_stage";
      };
    };
    description = ''
      Remote environments, keyed like the deploy workflows' `environment`
      input (production, staging). Read with `devenv eval` by the deploy
      workflows, `pull-app-backup` and `pull-app-db`.
    '';
  };
}
