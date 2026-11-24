{ lib, siteCfg }:
let
  isProduction = lib.elem siteCfg.appEnv [
    "production"
    "staging"
  ];
in
{
  APP_ENV = if isProduction then "prod" else "dev";
  APP_DEBUG = if isProduction then 0 else 1;
}
