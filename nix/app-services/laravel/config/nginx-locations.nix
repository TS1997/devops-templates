{
  config,
  siteCfg,
  phpSocket,
  ...
}:
let
  nginxPackage = config.services.ts1997.nginx.fullPackage;
in
{
  "/" = {
    tryFiles = "$uri $uri/ /index.php?$query_string";
  };

  "~ \\.php$" = {
    extraConfig = ''
      fastcgi_pass unix:${phpSocket};
      include ${nginxPackage}/conf/fastcgi_params;
      # Resolved path, so PHP (and OPcache) see the live release after a
      # switch of the `current` symlink.
      fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
      fastcgi_param DOCUMENT_ROOT $realpath_root;
      fastcgi_index index.php;
      fastcgi_hide_header X-Powered-By;
      fastcgi_read_timeout ${toString (siteCfg.maxExecutionTime + 60)}s;
      fastcgi_buffer_size 128k;
      fastcgi_buffers 16 64k;
      fastcgi_busy_buffers_size 256k;
    '';
  };

  "~ ^/livewire/" = {
    extraConfig = ''
      expires off;
      try_files $uri $uri/ /index.php?$query_string;
    '';
  };

  "/storage/" = {
    # sharedDir only exists on NixOS sites; devenv serves from workingDir.
    alias = "${siteCfg.sharedDir or siteCfg.workingDir}/storage/app/public/";
    extraConfig = ''
      expires 1y;
    '';
  };
}
