{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.pgsql;

  mkAuthRules = lib.concatMapStringsSep "\n" (
    { name, value }:
    ''
      local ${name} ${value.user} peer
      local ${name} postgres peer
    ''
  ) (lib.mapAttrsToList (name: value: { inherit name value; }) cfg);
in
{
  options.services.ts1997.pgsql = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            user = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "The PostgreSQL user for this database.";
            };

            extensions = lib.mkOption {
              type = with lib.types; coercedTo (listOf path) (path: _ignorePg: path) (functionTo (listOf path));
              default = _: [ ];
              example = lib.literalExpression "ps: with ps; [ postgis pg_repack ]";
              description = ''
                List of PostgreSQL extensions to install.
              '';
            };
          };
        }
      )
    );
    default = { };
    description = "List of PostgreSQL databases to enable.";
  };

  config = lib.mkIf (cfg != { }) {
    users = {
      users = lib.mkMerge (
        lib.mapAttrsToList (name: siteCfg: {
          ${siteCfg.user}.extraGroups = [ "postgres" ];
        }) cfg
      );

      groups = lib.mkMerge (
        lib.mapAttrsToList (name: siteCfg: {
          ${siteCfg.user} = {
            members = [
              "postgres"
            ];
          };
        }) cfg
      );
    };

    services.postgresql = {
      enable = true;
      package = pkgs.postgresql;
      extensions = ps: lib.unique (lib.concatMap (dbCfg: dbCfg.extensions ps) (lib.attrValues cfg));

      ensureDatabases = lib.mapAttrsToList (name: _: name) cfg;

      ensureUsers = lib.mapAttrsToList (name: dbCfg: {
        name = dbCfg.user;
        ensureDBOwnership = true;
      }) cfg;

      authentication = lib.mkAfter ''
        #type database DBuser auth-method
        ${mkAuthRules}
      '';
    };

    systemd.services.create-db-extensions = {
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.postgresql ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        ExecStart = pkgs.writeShellScript "create-db-extensions" ''
          set -e
          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (
              name: dbCfg:
              let
                extPkgs = dbCfg.extensions pkgs.postgresql.pkgs;
                extNames = builtins.map (extPkg: extPkg.pname or extPkg.name or "unknown") extPkgs;
              in
              lib.concatStringsSep "\n" (
                builtins.map (extName: ''
                  psql -d ${name} -c "CREATE EXTENSION IF NOT EXISTS \"${extName}\";"
                '') extNames
              )
            ) cfg
          )}
        '';
      };
    };
  };
}
