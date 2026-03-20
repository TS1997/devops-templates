{
  config,
  lib,
  name,
  siteCfg,
}:
let
  mailpitCfg = config.services.ts1997.mailpit or null;
  dbCfg = config.services.ts1997.mysql;

  wpHome =
    if siteCfg.enableSsl then
      "https://${siteCfg.domain}:${toString siteCfg.sslPort}"
    else
      "http://${siteCfg.domain}:${toString siteCfg.port}";
in
{
  WP_ENV = "development";
  WP_HOME = wpHome;
  WP_SITEURL = "${wpHome}/wp";

  DB_NAME = "${siteCfg.database.name}";
  DB_USER = "${siteCfg.database.user}";
  DB_PASSWORD = "${siteCfg.database.password or ""}";
  DB_HOST = "${dbCfg.host}:${toString dbCfg.port}";

  DB_TABLE_PREFIX = "${siteCfg.tablePrefix}";

  SMTP_HOST = if (mailpitCfg != null && mailpitCfg.enable) then mailpitCfg.smtp.host else "127.0.0.1";
  SMTP_PORT = if (mailpitCfg != null && mailpitCfg.enable) then mailpitCfg.smtp.port else 1025;
}
