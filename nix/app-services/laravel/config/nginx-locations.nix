{
  config,
  siteCfg,
  phpSocket,
  ...
}:
let
  nginxPackage = config.services.ts1997.nginx.fullPackage;

  # With zero-downtime deploys the web root is a symlink (current -> releases/<sha>).
  # Resolve it per request so PHP/OPcache see the real release path and pick up
  # the new release immediately after the symlink is switched.
  docRoot = if (siteCfg.zeroDowntime.enable or false) then "$realpath_root" else "$document_root";
in
{
  "/" = {
    tryFiles = "$uri $uri/ /index.php?$query_string";
  };

  "~ \\.php$" = {
    extraConfig = ''
      fastcgi_pass unix:${phpSocket};
      fastcgi_param SCRIPT_FILENAME ${docRoot}$fastcgi_script_name;
      fastcgi_index index.php;
      fastcgi_hide_header X-Powered-By;
      fastcgi_read_timeout ${toString (siteCfg.maxExecutionTime + 60)}s;
      fastcgi_buffer_size 128k;
      fastcgi_buffers 16 64k;
      fastcgi_busy_buffers_size 256k;
      include ${nginxPackage}/conf/fastcgi_params;
      fastcgi_param DOCUMENT_ROOT ${docRoot};
    '';
  };

  "~ ^/livewire/" = {
    extraConfig = ''
      expires off;
      try_files $uri $uri/ /index.php?$query_string;
    '';
  };

  "/storage/" = {
    alias = "${siteCfg.workingDir}/storage/app/public/";
    extraConfig = ''
      expires 1y;
    '';
  };
}
