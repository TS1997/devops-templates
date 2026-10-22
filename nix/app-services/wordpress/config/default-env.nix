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
  opensearchCfg = config.services.ts1997.opensearch;
in
{
  WP_ENV = siteCfg.appEnv;
  WP_HOME = siteCfg.appUrl;
  WP_SITEURL = "${siteCfg.appUrl}/wp";
  WP_DEBUG_LOG = config.languages.php.fpm.settings.error_log or "/var/log/php-fpm/${name}-error.log";

  DB_NAME = "${siteCfg.database.name}";
  DB_USER = "${siteCfg.database.user}";
  DB_PASSWORD = "${siteCfg.database.password or ""}";
  DB_HOST = "localhost:${dbCfg.socket}";

  DB_PREFIX = "${siteCfg.tablePrefix}";

  SMTP_HOST = if (mailpitCfg != null && mailpitCfg.enable) then mailpitCfg.smtp.host else "127.0.0.1";
  SMTP_PORT = if (mailpitCfg != null && mailpitCfg.enable) then mailpitPorts.smtp.value else 1025;
}
// lib.optionalAttrs siteCfg.opensearch.enable {
  EP_HOST = opensearchCfg.url;
  # The OpenSearch node is shared by all sites on a host, so indices must be namespaced per site.
  EP_INDEX_PREFIX = siteCfg.appName;
}
