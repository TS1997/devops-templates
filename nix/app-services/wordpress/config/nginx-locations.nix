{
  config,
  lib,
  siteCfg,
  phpSocket,
  ...
}:
let
  nginxPackage = config.services.ts1997.nginx.fullPackage;
  fallbacks = siteCfg.assetFallbackUrls;
  hasFallbacks = builtins.length fallbacks > 0;
  # nginx's `try_files` only ever honours the FIRST `@name` token it reaches;
  # it does not fall through multiple named locations if an earlier one
  # doesn't 404. So when there's more than one fallback (e.g. one server
  # block serving several domains via `extraDomains`, each wanting to
  # proxy to a different upstream), we must dispatch to the right one
  # ourselves based on $host, behind a single named location.
  singleFallback = builtins.length fallbacks == 1;
  fallbackLocationName = if singleFallback then (builtins.head fallbacks).name else "@assetFallback";

  defaultFallback = lib.findFirst (fallback: (fallback.hosts or [ ]) == [ ]) (builtins.head fallbacks) fallbacks;
  hostFallbacks = builtins.filter (fallback: (fallback.hosts or [ ]) != [ ]) fallbacks;

  hostDispatchConfig = lib.concatMapStringsSep "\n" (
    fallback: lib.concatMapStringsSep "\n" (host: ''if ($host = "${host}") { set $assetFallbackUrl "${fallback.url}"; }'') fallback.hosts
  ) hostFallbacks;
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
          add_header X-Frame-Options SAMEORIGIN;
          add_header X-Content-Type-Options nosniff;
          try_files $uri ${fallbackLocationName};
        '';
      };
    }
    // (
      if singleFallback then
        {
          "${fallbackLocationName}" = {
            extraConfig = ''
              resolver 8.8.8.8;
              proxy_ssl_server_name on;
              proxy_pass ${(builtins.head fallbacks).url};
              proxy_redirect http:// https://;
            '';
          };
        }
      else
        {
          "${fallbackLocationName}" = {
            extraConfig = ''
              resolver 8.8.8.8;
              proxy_ssl_server_name on;
              set $assetFallbackUrl "${defaultFallback.url}";
              ${hostDispatchConfig}
              proxy_pass $assetFallbackUrl$request_uri;
              proxy_redirect http:// https://;
            '';
          };
        }
    )
  else
    { }
)
