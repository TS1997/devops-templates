{
  config,
  lib,
  siteCfg,
  phpSocket,
  ...
}:
let
  nginxPackage = config.services.ts1997.nginx.fullPackage;
  hasFallbacks = builtins.length siteCfg.assetFallbackUrls > 0;
  fallbackNames = map (f: f.name) siteCfg.assetFallbackUrls;
in
{
  "/" = {
    tryFiles = "$uri $uri/ /index.php?$args";
  };

  "~ \\.php$" = {
    extraConfig = ''
      fastcgi_pass unix:${phpSocket};
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      fastcgi_index index.php;
      fastcgi_hide_header X-Powered-By;
      fastcgi_read_timeout ${toString (siteCfg.maxExecutionTime + 60)}s;
      include ${nginxPackage}/conf/fastcgi_params;
    '';
  };

  # Deny access to sensitive WordPress files
  "~ /\\.ht" = {
    extraConfig = ''
      deny all;
    '';
  };

  "~ ^/wp-content/uploads/.*\\.php$" = {
    extraConfig = ''
      deny all;
    '';
  };
}
// (
  if hasFallbacks then
    {
      "~* \\.(?:jpg|jpeg|gif|pdf|png|webp|ico|cur|gz|svg|mp4|mp3|ogg|ogv|webm|htc)$" = {
        extraConfig = ''
          expires 1y;
          access_log off;
          add_header Access-Control-Allow-Origin *;
          try_files $uri ${lib.concatStringsSep " " fallbackNames};
        '';
      };
    }
    // builtins.listToAttrs (
      map (fallback: {
        name = fallback.name;
        value = {
          extraConfig = ''
            resolver 8.8.8.8;
            proxy_ssl_server_name on;
            proxy_pass ${fallback.url};
            proxy_redirect http:// https://;
          '';
        };
      }) siteCfg.assetFallbackUrls
    )
  else
    { }
)
