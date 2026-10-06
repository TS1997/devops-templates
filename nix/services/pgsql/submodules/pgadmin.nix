{
  config,
  lib,
  pkgs,
  util,
  ...
}:
let
  pgsqlCfg = config.services.ts1997.pgsql;
  cfg = pgsqlCfg.pgAdmin;
  dbCfg = lib.head pgsqlCfg.databases;
  port = toString config.processes.pgadmin.ports.main.value;

  stateDir = "${util.values.devenvState}/pgadmin";

  configDistro = pkgs.writeText "pgadmin_config_distro.py" ''
    DATA_DIR = r"${stateDir}"
    DEFAULT_SERVER = "${cfg.host}"
    DEFAULT_SERVER_PORT = ${port}
    MASTER_PASSWORD_REQUIRED = False
  '';

  servers = pkgs.writeText "pgadmin_servers.json" (
    builtins.toJSON {
      Servers = {
        "1" = {
          Name = "PostgreSQL";
          Group = "Servers";
          Host = pgsqlCfg.socket;
          Port = pgsqlCfg.port;
          MaintenanceDB = "postgres";
          Username = dbCfg.user;
          ConnectionParameters = {
            sslmode = "prefer";
          };
        };
      };
    }
  );

  pgpass = pkgs.writeText "pgadmin_pgpass" ''
    *:${toString pgsqlCfg.port}:*:${dbCfg.user}:${dbCfg.password}
  '';
in
{
  config = lib.mkIf (cfg.enable) {
    scripts.pgadmin.exec = util.openUrl "http://${cfg.host}:${port}/";

    processes.pgadmin = {
      ports.main.allocate = cfg.port;
      exec = ''
        install -dm700 "${stateDir}"

        export CONFIG_DISTRO_FILE_PATH="${configDistro}"
        export PGPASSFILE="${pgpass}"

        "${cfg.package}/bin/pgadmin4-cli" setup-db
        "${cfg.package}/bin/pgadmin4-cli" load-servers "${servers}" --replace

        exec "${cfg.package}/bin/pgadmin4"
      '';
      ready = {
        http.get = {
          host = cfg.host;
          port = config.processes.pgadmin.ports.main.value;
          path = "/";
        };
        initial_delay = 2;
        period = 1;
        probe_timeout = 5;
        success_threshold = 1;
        failure_threshold = 30;
      };
    };
  };
}
