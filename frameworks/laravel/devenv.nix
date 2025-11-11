{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ts1997.laravel;
in
{
  options.services.ts1997.laravel = lib.mkOption {
    type = lib.types.submodule (
      { config, ... }:
      {
        imports = [ ./options/devenv.nix ];
      }
    );
    default = { };
    description = "Laravel application configuration.";
  };

  config = lib.mkIf (cfg.enable) {
    services.ts1997.nginx = {
      enable = true;
      serverName = cfg.domain;
      root = cfg.webRoot;
      port = cfg.port;
      sslPort = cfg.sslPort;
      enableSsl = cfg.enableSsl;
      locations = {
        "/" = {
          tryFiles = "$uri $uri/ /index.php?$query_string";
        };

        "~ \\.php$" = {
          extraConfig = ''
            fastcgi_pass unix:${config.languages.php.fpm.pools.web.socket};
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
          alias = "${cfg.workingDir}/storage/app/public/";
          extraConfig = ''
            expires 1y;
          '';
        };
      };
    };

    services.ts1997.php = {
      enable = true;
    };
  };
}
