{ config, siteCfg }:
if siteCfg.database.driver == "mysql" then
  {
    socket = "/run/mysqld/mysqld.sock";
  }
else if siteCfg.database.driver == "pgsql" then
  {
    host = "/run/postgresql";
    port = config.services.postgresql.settings.port;
  }
else
  { }
