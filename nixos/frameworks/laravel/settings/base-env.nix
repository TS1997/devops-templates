{ name, siteCfg }:
{
  APP_NAME = siteCfg.appName;
  APP_ENV = siteCfg.appEnv;
  APP_DEBUG = if siteCfg.appEnv == "production" then "false" else "true";
  APP_TIMEZONE = siteCfg.timezone;
  APP_URL = if siteCfg.forceWWW then "https://www.${siteCfg.domain}" else "https://${siteCfg.domain}";

  APP_LOCALE = siteCfg.locale;
  APP_FALLBACK_LOCALE = siteCfg.locale;
  APP_FAKER_LOCALE = "en_US";

  APP_MAINTENANCE_DRIVER = "file";
  APP_MAINTENANCE_STORE = "database";

  PHP_CLI_SERVER_WORKERS = "4";

  BCRYPT_ROUNDS = "12";

  LOG_CHANNEL = "stack";
  LOG_STACK = "single";
  LOG_DEPRECATIONS_CHANNEL = "null";
  LOG_LEVEL = "debug";

  DB_CONNECTION = siteCfg.database.connection;
  DB_SOCKET = siteCfg.database.socket;
  DB_DATABASE = siteCfg.database.name;
  DB_USERNAME = siteCfg.database.user;

  SESSION_DRIVER = "database";
  SESSION_LIFETIME = "120";
  SESSION_ENCRYPT = "false";
  SESSION_PATH = "/";
  SESSION_DOMAIN = "null";

  BROADCAST_CONNECTION = "log";
  FILESYSTEM_DISK = "local";
  QUEUE_CONNECTION = "database";

  CACHE_STORE = "database";
  CACHE_PREFIX = "";

  MEMCACHED_HOST = "127.0.0.1";

  REDIS_CLIENT = "phpredis";
  REDIS_HOST = siteCfg.redis.socket;
  REDIS_PASSWORD = "null";
  REDIS_PORT = "6379";

  MAIL_MAILER = siteCfg.mail.mailer;
  MAIL_SCHEME = "null";
  MAIL_HOST = siteCfg.mail.host;
  MAIL_PORT = builtins.toString siteCfg.mail.port;
  MAIL_USERNAME = siteCfg.mail.username;
  MAIL_PASSWORD = siteCfg.mail.password;
  MAIL_FROM_ADDRESS = siteCfg.mail.from.address;
  MAIL_FROM_NAME = siteCfg.mail.from.name;

  AWS_ACCESS_KEY_ID = "";
  AWS_SECRET_ACCESS_KEY = "";
  AWS_DEFAULT_REGION = "us-east-1";
  AWS_BUCKET = "";
  AWS_USE_PATH_STYLE_ENDPOINT = "false";

  VITE_APP_NAME = "${siteCfg.appName}";
}
