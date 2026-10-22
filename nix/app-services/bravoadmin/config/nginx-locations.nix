{
  config,
  lib,
  siteCfg,
  phpSocket,
}:
let
  nginxPackage = config.services.ts1997.nginx.fullPackage;
  readTimeout = "${toString (siteCfg.maxExecutionTime + 60)}s";
  fallbackPaths = lib.concatStringsSep "|" siteCfg.assetFallbackPaths;
in
{
  "/" = {
    tryFiles = "$uri $uri/ /index.php?$args";
  };

  "~ \\.php$" = {
    tryFiles = "$uri /index.php?$args";
    extraConfig = ''
      fastcgi_pass unix:${phpSocket};
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      fastcgi_index index.php;
      fastcgi_read_timeout ${readTimeout};
      include ${nginxPackage}/conf/fastcgi_params;
    '';
  };

  "~ /\\.ht" = {
    extraConfig = "deny all;";
  };
}
// lib.optionalAttrs siteCfg.crm.enable {
  # crm served like bravo-dev's Apache alias, scripts run from the crm dir
  "= /crm" = {
    return = "301 /crm/";
  };

  "^~ /crm/" = {
    alias = "${siteCfg.crm.dir}/";
    extraConfig = ''
      index index.php;

      location ~ /\.ht {
        deny all;
      }

      location ~ \.php$ {
        if (!-f $request_filename) {
          return 404;
        }
        fastcgi_pass unix:${phpSocket};
        fastcgi_read_timeout ${readTimeout};
        include ${nginxPackage}/conf/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $request_filename;
        fastcgi_param DOCUMENT_ROOT ${siteCfg.webRoot};
      }
    '';
  };
}
// lib.optionalAttrs (siteCfg.productionUrl != null && siteCfg.assetFallbackPaths != [ ]) {
  # Uploaded media is not in git, fetch missing files from production
  "~ ^/(${fallbackPaths})/" = {
    tryFiles = "$uri @production";
  };

  "@production" = {
    extraConfig = ''
      resolver 1.1.1.1 ipv6=off;
      proxy_ssl_server_name on;
      proxy_pass ${siteCfg.productionUrl}$request_uri;
    '';
  };
}
