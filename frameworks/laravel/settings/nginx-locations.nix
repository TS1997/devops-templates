{
  pkgs,
  siteCfg,
  phpSocket,
  ...
}:
{
  "/" = {
    tryFiles = "$uri $uri/ /index.php?$query_string";
  };

  "~ \\.php$" = {
    extraConfig = ''
      fastcgi_pass unix:${phpSocket};
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      fastcgi_index index.php;
      fastcgi_hide_header X-Powered-By;
      include ${pkgs.nginx}/conf/fastcgi_params;
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
