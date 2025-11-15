{
  lib,
  siteCfg,
  dbSocket,
  redisSocket,
}:
lib.mapAttrs (_: lib.mkDefault) (
  {
    APP_NAME = siteCfg.appName;
    APP_ENV = siteCfg.appEnv;
    APP_DEBUG = if siteCfg.appEnv == "production" then "false" else "true";
    APP_TIMEZONE = "Europe/Stockholm";
    APP_URL =
      if (siteCfg.forceWWW or false) then
        "https://www.${siteCfg.domain}"
      else
        "https://${siteCfg.domain}";

    APP_LOCALE = "en";
    APP_FALLBACK_LOCALE = "en";
    APP_FAKER_LOCALE = "en_US";

    APP_MAINTENANCE_DRIVER = "file";
    APP_MAINTENANCE_STORE = "database";

    PHP_CLI_SERVER_WORKERS = 4;

    BCRYPT_ROUNDS = 12;

    LOG_CHANNEL = "stack";
    LOG_STACK = "single";
    LOG_DEPRECATIONS_CHANNEL = null;
    LOG_LEVEL = "debug";

    DB_CONNECTION = siteCfg.database.driver;
    DB_SOCKET = dbSocket;
    DB_DATABASE = siteCfg.database.name;
    DB_USERNAME = siteCfg.database.user;

    SESSION_DRIVER = "database";
    SESSION_LIFETIME = 120;
    SESSION_ENCRYPT = false;
    SESSION_PATH = "/";
    SESSION_DOMAIN = null;

    BROADCAST_CONNECTION = "log";
    FILESYSTEM_DISK = "local";
    QUEUE_CONNECTION = "database";

    CACHE_STORE = "database";
    CACHE_PREFIX = "";

    MEMCACHED_HOST = "127.0.0.1";

    REDIS_CLIENT = "phpredis";
    REDIS_HOST = redisSocket;
    REDIS_PASSWORD = "null";
    REDIS_PORT = "6379";

    MAIL_MAILER = "log";
    MAIL_SCHEME = "null";
    MAIL_HOST = "127.0.0.1";
    MAIL_PORT = "2525";
    MAIL_USERNAME = "null";
    MAIL_PASSWORD = "null";
    MAIL_FROM_ADDRESS = "hello@example.com";
    MAIL_FROM_NAME = siteCfg.appName;

    AWS_ACCESS_KEY_ID = "";
    AWS_SECRET_ACCESS_KEY = "";
    AWS_DEFAULT_REGION = "us-east-1";
    AWS_BUCKET = "";
    AWS_USE_PATH_STYLE_ENDPOINT = false;

    VITE_APP_NAME = siteCfg.appName;
  }
  // lib.optionalAttrs ((siteCfg.database.password or "") != "") {
    DB_PASSWORD = siteCfg.database.password;
  }
)
