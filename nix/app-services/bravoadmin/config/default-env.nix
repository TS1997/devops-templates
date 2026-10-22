{ siteCfg, util }:
let
  db = siteCfg.database;
in
{
  BRAVO_ENV = "local-dev";
  BRAVO_DB_SERVER = "localhost";
  BRAVO_DB_NAME = db.name;
  BRAVO_DB_USER = db.user;
  BRAVO_DB_PASSWORD = db.password;
  BRAVO_CRM_DB_SERVER = "localhost";
  BRAVO_CRM_DB_NAME = db.crmName;
  BRAVO_CRM_DB_USER = db.user;
  BRAVO_CRM_DB_PASSWORD = db.password;
  BRAVO_SYS_LOGS_DIR = "${util.values.devenvState}/bravo-logs";
  BRAVO_SWEDBANKPAY_MODE = "test";
}
