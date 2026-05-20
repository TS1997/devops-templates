let
  siteName = "{{SITE_NAME}}";
  siteSlug = "{{SITE_SLUG}}"; # No hyphens or underscores please
in
{
  config = {
    services.ts1997.laravelSite = {
      enable = true;
      appName = siteName;
      domain = "${siteSlug}.local";
      database = {
        name = siteSlug;
      };

      env = {
        APP_KEY = "{{APP_KEY}}";
      };
    };

    processes = {
      ts-transformer.exec = "php artisan typescript:transform --watch";
    };
  };
}
