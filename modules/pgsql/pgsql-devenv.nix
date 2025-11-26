{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ts1997.pgsql;

  # Helper to get extension names from package attributes
  extensionNames = extList: builtins.map (extPkg: extPkg.pname or extPkg.name or "unknown") extList;

  # Generate SQL for creating extensions
  initialScript =
    if cfg.extensions != null then
      let
        extPkgs = cfg.extensions pkgs.postgresql.pkgs;
        extNames = extensionNames extPkgs;
      in
      builtins.concatStringsSep "\n" (
        builtins.map (name: "CREATE EXTENSION IF NOT EXISTS \"${name}\";") extNames
      )
    else
      "";
in
{
  options.services.ts1997.pgsql = {
    enable = lib.mkEnableOption "Enable PostgreSQL database.";

    name = lib.mkOption {
      type = lib.types.str;
      default = "default_db";
      description = "The name of the PostgreSQL database.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "admin";
      description = "The PostgreSQL database user.";
    };

    password = lib.mkOption {
      type = lib.types.str;
      default = "1234";
      description = "The PostgreSQL database password.";
    };

    extensions = lib.mkOption {
      type = with lib.types; nullOr (functionTo (listOf package));
      default = null;
      example = extensions: [
        extensions.pg_cron
        extensions.postgis
        extensions.timescaledb
      ];
      description = ''
        Additional PostgreSQL extensions to install.

        The available extensions are:

        ${lib.concatLines (builtins.map (x: "- " + x) (builtins.attrNames pkgs.postgresql.pkgs))}
      '';
    };
  };

  config = lib.mkIf (cfg.enable) {
    services.postgres = {
      enable = cfg.enable;
      package = pkgs.postgresql;
      extensions = cfg.extensions;

      initialDatabases = [
        {
          name = cfg.name;
          user = cfg.user;
          pass = cfg.password;
        }
      ];

      initialScript = lib.mkIf (initialScript != "") ''
        \c ${cfg.name}
        ${initialScript} 
      '';
    };

    scripts = {
      psql-local.exec = "psql -U ${cfg.user} ${cfg.name} \"$@\"";
    };
  };
}
