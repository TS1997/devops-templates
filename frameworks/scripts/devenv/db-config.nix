{ config, siteCfg }:
if siteCfg.database.driver == "mysql" then
  {
    socket = config.env.MYSQL_UNIX_PORT;
  }
else if siteCfg.database.driver == "pgsql" then
  {
    host = config.env.PGHOST;
    port = config.env.PGPORT;
  }
else
  { }
