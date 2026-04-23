{
  config,
  lib,
  name,
  siteCfg,
}:
let
  mailpitCfg = config.services.ts1997.mailpit or null;
  mailpitPorts = config.processes.mailpit.ports or null;
  dbCfg = config.services.ts1997.mysql;
in
{
  WP_ENV = siteCfg.appEnv;
  WP_HOME = siteCfg.appUrl;
  WP_SITEURL = "${siteCfg.appUrl}/wp";
  WP_DEBUG_LOG = config.languages.php.fpm.settings.error_log;

  DB_NAME = "${siteCfg.database.name}";
  DB_USER = "${siteCfg.database.user}";
  DB_PASSWORD = "${siteCfg.database.password or ""}";
  DB_HOST = "localhost:${dbCfg.socket}";

  DB_PREFIX = "${siteCfg.tablePrefix}";

  SMTP_HOST = if (mailpitCfg != null && mailpitCfg.enable) then mailpitCfg.smtp.host else "127.0.0.1";
  SMTP_PORT = if (mailpitCfg != null && mailpitCfg.enable) then mailpitPorts.smtp.value else 1025;

}
