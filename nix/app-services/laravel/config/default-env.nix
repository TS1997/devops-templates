{
  config,
  lib,
  name,
  siteCfg,
}:
let
  redisCfg = config.services.ts1997.redis.servers.${name} or null;
  mailpitCfg = config.services.ts1997.mailpit or null;

  dbCfg =
    if (siteCfg.database.driver == "pgsql") then
      config.services.ts1997.pgsql
    else
      config.services.ts1997.mysql;
in
{
  APP_NAME = "${siteCfg.appName}";
  APP_ENV = "${siteCfg.appEnv}";
  APP_DEBUG = if siteCfg.appEnv == "production" then false else true;
  APP_TIMEZONE = "Europe/Stockholm";
  APP_URL = "${siteCfg.appUrl}";

  APP_LOCALE = "${siteCfg.locale}";
  APP_FALLBACK_LOCALE = "${siteCfg.locale}";
  APP_FAKER_LOCALE = "en_US";

  APP_MAINTENANCE_DRIVER = "file";
  APP_MAINTENANCE_STORE = "database";

  PHP_CLI_SERVER_WORKERS = 4;

  BCRYPT_ROUNDS = 12;

  LOG_CHANNEL = "stack";
  LOG_STACK = "single";
  LOG_DEPRECATIONS_CHANNEL = null;
  LOG_LEVEL = "debug";

  # Laravel requires PostgreSQL socket as db_host rather than db_socket compared to MySQL
  DB_CONNECTION = "${siteCfg.database.driver}";
  DB_HOST = if siteCfg.database.driver == "pgsql" then "${dbCfg.socket}" else "${dbCfg.host}";
  DB_PORT = dbCfg.port;
  DB_SOCKET = if siteCfg.database.driver == "pgsql" then null else "${dbCfg.socket}";
  DB_DATABASE = "${siteCfg.database.name}";
  DB_USERNAME = "${siteCfg.database.user}";
  DB_PASSWORD = "${siteCfg.database.password or ""}";

  SESSION_DRIVER = "database";
  SESSION_LIFETIME = 120;
  SESSION_ENCRYPT = false;
  SESSION_PATH = "/";
  SESSION_DOMAIN = null;

  SANCTUM_STATEFUL_DOMAINS = lib.concatStringsSep "," (
    map (url: lib.replaceStrings [ "http://" "https://" ] [ "" "" ] url) (
      [ siteCfg.appUrl ] ++ siteCfg.extraAppUrls
    )
  );

  BROADCAST_CONNECTION = "log";
  FILESYSTEM_DISK = "local";
  QUEUE_CONNECTION = siteCfg.queue.connection;

  CACHE_STORE = "database";
  CACHE_PREFIX = "";

  MEMCACHED_HOST = "127.0.0.1";

  REDIS_CLIENT = "phpredis";
  REDIS_HOST = if (redisCfg != null && redisCfg.enable) then redisCfg.socket else null;
  REDIS_PASSWORD = null;
  REDIS_PORT = if (redisCfg != null && redisCfg.enable) then redisCfg.port else null;

  MAIL_MAILER = if (mailpitCfg != null && mailpitCfg.enable) then "smtp" else "log";
  MAIL_SCHEME = null;
  MAIL_HOST = if (mailpitCfg != null && mailpitCfg.enable) then mailpitCfg.smtp.host else "127.0.0.1";
  MAIL_PORT = if (mailpitCfg != null && mailpitCfg.enable) then mailpitCfg.smtp.port else 2525;
  MAIL_USERNAME = null;
  MAIL_PASSWORD = null;
  MAIL_FROM_ADDRESS = "hello@example.com";
  MAIL_FROM_NAME = "${siteCfg.appName}";

  AWS_ACCESS_KEY_ID = "";
  AWS_SECRET_ACCESS_KEY = "";
  AWS_DEFAULT_REGION = "us-east-1";
  AWS_BUCKET = "";
  AWS_USE_PATH_STYLE_ENDPOINT = false;

  VITE_APP_NAME = "${siteCfg.appName}";
}
