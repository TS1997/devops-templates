{
  pkgs,
  ...
}:
let
  siteName = "Laravel Template";
  siteSlug = "laraveltemplate"; # No hyphens please
in
{
  imports = [
    ./devenv/scripts/testing.nix
    ./devenv/scripts/utils.nix
  ];

  config = {
    packages = [ pkgs.laravel ];

    services.ts1997.laravelSite = {
      appName = siteName;
      locale = "sv";
      domain = "${siteSlug}.local";
      database = {
        name = siteSlug;
      };
      nodejs.package = pkgs.nodejs_22;
      enableSsl = false;

      env = {
        APP_KEY = "base64:HCfHGOmJRvmboLiWm/V3JpF0G8xADJSfVgeCUjZ3+U0=";
      };
    };
  };
}
