{
  lib,
  siteCfg,
  dbCfg,
  redisSocket,
  isDevenv,
}:
let
  appUrl =
    if (siteCfg.forceWWW or false) then
      "https://www.${siteCfg.domain}"
    else
      "https://${siteCfg.domain}";

  appUrlWithPort =
    if isDevenv && siteCfg.enableSsl then
      "${appUrl}:${toString siteCfg.sslPort}"
    else if isDevenv then
      "${appUrl}:${toString siteCfg.port}"
    else
      appUrl;

  domains = [ siteCfg.domain ] ++ siteCfg.extraDomains;
  domainsWithPorts = lib.concatMap (
    domain:
    if isDevenv then
      [
        "${domain}:${toString siteCfg.port}"
        "${domain}:${toString siteCfg.sslPort}"
      ]
    else if siteCfg.forceWWW then
      [ "www.${domain}" ]
    else
      [ domain ]
  ) domains;

  sanctumStatefulDomains = lib.concatStringsSep "," domainsWithPorts;
in
{
  APP_NAME = "${siteCfg.appName}";
  APP_ENV = siteCfg.appEnv;
  APP_DEBUG = if siteCfg.appEnv == "production" then "false" else "true";
  APP_TIMEZONE = "Europe/Stockholm";
  APP_URL = appUrlWithPort;

  APP_LOCALE = siteCfg.locale;
  APP_FALLBACK_LOCALE = siteCfg.locale;
  APP_FAKER_LOCALE = "en_US";

  APP_MAINTENANCE_DRIVER = "file";
  APP_MAINTENANCE_STORE = "database";

  PHP_CLI_SERVER_WORKERS = 4;

  BCRYPT_ROUNDS = 12;

  LOG_CHANNEL = "stack";
  LOG_STACK = "single";
  LOG_DEPRECATIONS_CHANNEL = null;
  LOG_LEVEL = "debug";

  DB_CONNECTION = dbCfg.driver;
  DB_HOST = dbCfg.host;
  DB_PORT = dbCfg.port;
  DB_SOCKET = dbCfg.socket;
  DB_DATABASE = siteCfg.database.name;
  DB_USERNAME = siteCfg.database.user;
  DB_PASSWORD = siteCfg.database.password or "";
  SESSION_DRIVER = "database";
  SESSION_LIFETIME = 120;
  SESSION_ENCRYPT = false;
  SESSION_PATH = "/";
  SESSION_DOMAIN = null;

  SANCTUM_STATEFUL_DOMAINS = sanctumStatefulDomains;

  BROADCAST_CONNECTION = "log";
  FILESYSTEM_DISK = "local";
  QUEUE_CONNECTION = "database";

  CACHE_STORE = "database";
  CACHE_PREFIX = "";

  MEMCACHED_HOST = "127.0.0.1";

  REDIS_CLIENT = "phpredis";
  REDIS_HOST = redisSocket;
  REDIS_PASSWORD = null;
  REDIS_PORT = "6379";

  MAIL_MAILER = "smtp";
  MAIL_SCHEME = null;
  MAIL_HOST = "127.0.0.1";
  MAIL_PORT = 1025;
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
