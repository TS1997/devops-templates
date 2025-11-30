{
  config,
  pkgs,
  lib,
  ...
}:
let
  sites = config.services.ts1997.wordpress.sites;

  phpFpmSettings = import ../../modules/phpfpm/config/pool-settings.nix;

  # inherit (config.terraflake.input) node;
  inherit (lib) types;

  nginxUser = config.services.nginx.user;

  setupCache =
    site:
    pkgs.writeShellScriptBin "set-up-cache" ''
      # SET UP PAGE CACHE DIRECTORY FOR FASTCGI CACHE
      mkdir -p /var/run/nginx-cache/${site.appName}
      chown -R ${nginxUser}:${nginxUser} /var/run/nginx-cache/${site.appName}

      # Don't do this. Find a better way instead of allowing all with 777
      chmod -R 777 /var/run/nginx-cache/${site.appName}
    '';
in
{
  options.services.ts1997.wordpress = {
    enable = lib.mkEnableOption "WordPress service";

    sites = lib.mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            imports = [
              ./submodules/wordpress-site.nix
            ];
          }
        )
      );
      description = "WordPress sites";
    };
  };

  config =
    lib.mkIf (sites != { }) {
      users.users = lib.mkMerge (
        lib.mapAttrsToList (name: site: {
          ${site.user} = {
            isNormalUser = true;
            createHome = true;
            extraGroups = [ "nginx" ];
            home = site.home;
            group = site.user;
          };
        }) sites
      );

      users.groups = lib.mkMerge (
        lib.mapAttrsToList (name: site: {
          ${site.user} = {
            members = [
              site.user
            ];
          };
        }) sites
      );

      services.mysql = {
        initialDatabases = lib.mapAttrsToList (name: site: { name = "${site.dbName}"; }) sites;
        ensureDatabases = lib.mapAttrsToList (name: site: "${site.dbName}") sites;
        ensureUsers = lib.mapAttrsToList (name: site: {
          name = site.user;
          ensurePermissions = {
            "${site.dbName}.*" = "ALL PRIVILEGES";
          };
        }) sites;
      };

      services.redis.servers = lib.mkMerge (
        lib.mapAttrsToList (name: site: {
          ${site.user} = {
            enable = true;
            user = site.user;
            group = site.user;
            port = 0; # Listen only on unix socket
            unixSocket = "/run/redis-${site.user}/redis.sock";
          };
        }) sites
      );

      services.phpfpm.pools = lib.mkMerge (
        lib.mapAttrsToList (name: site: {
          ${site.user} = {
            user = site.user;
            settings = phpFpmSettings // {
              "listen.owner" = config.services.nginx.user;
              "access.log" = "/var/log/${site.user}-phpfpm-access.log";
            };
            phpOptions = ''
              error_log = /var/log/${site.user}/php-error.log
              error_reporting = -1
              log_errors = On
              log_errors_max_len = 0
            '';
            phpEnv = {
              PATH = lib.makeBinPath [ pkgs.php ];
              ENV_FILE_PATH = "${site.home}";
            };
          };
        }) sites
      );

      services.nginx = {
        appendHttpConfig = lib.concatMapStringsSep "\n" (site: ''
          fastcgi_cache_path /var/run/nginx-cache/${site.appName} levels=1:2 keys_zone=${site.appName}:100m inactive=45m;
        '') (lib.attrValues sites);

        virtualHosts = lib.mkMerge (
          lib.mapAttrsToList (name: site: {
            ${site.domain} = {
              enableACME = site.ssl.enable;
              forceSSL = site.ssl.force;
              root = "${site.package}/share/php/${site.projectDir}/web";
              basicAuth = lib.mkIf site.basicAuth.enable {
                ${site.user} = site.user;
              };
              extraConfig = ''
                set $skip_cache 0;

                # POST requests and urls with a query string should always go to PHP
                if ($request_method = POST) {
                    set $skip_cache 1;
                }   
                if ($query_string != "") {
                    set $skip_cache 1;
                }   

                # Don't cache uris containing the following segments
                if ($request_uri ~* "/wp-admin/|/xmlrpc.php|wp-.*.php|/feed/|index.php|sitemap(_index)?.xml") {
                    set $skip_cache 1;
                }   

                # Don't use the cache for logged in users or recent commenters
                # We should look into adding a seperate cookie for Admin-users, since this will disable page cache for ALL logged in users.
                if ($http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in") {
                    set $skip_cache 1;
                }

                # Don't use the cache for users with items in their cart
                # Should perhaps look at the boolean value instead of only its presence
                if ($http_cookie ~* "woocommerce_items_in_cart") {
                    set $skip_cache 1;
                }

                client_max_body_size 64m;
              '';

              locations."/".extraConfig = ''
                index index.php;
                try_files $uri $uri/ /index.php$is_args$args;
              '';

              locations."~ \\.php$".extraConfig = ''
                # CACHE
                fastcgi_cache_bypass $skip_cache;
                fastcgi_no_cache $skip_cache;
                fastcgi_cache ${site.appName};
                fastcgi_cache_key "$scheme$request_method$host$request_uri";
                fastcgi_cache_valid 200 301 302 30m;

                # Add these headers for debugging
                add_header X-Cache-Status $upstream_cache_status;

                # PARAMS
                fastcgi_pass unix:${config.services.phpfpm.pools.${site.user}.socket};
                fastcgi_index index.php;
                include ${pkgs.nginx}/conf/fastcgi_params;
                fastcgi_param SCRIPT_FILENAME $request_filename;
                fastcgi_buffer_size 512k;
                fastcgi_buffers 16 512k;
              '';

              locations."~ /purge(/.*)".extraConfig = ''
                fastcgi_cache_purge ${site.appName} "$scheme$request_method$host$1";
              '';

              locations."/app/uploads/" = {
                alias = "/var/lib/${site.user}/app/uploads/";
                extraConfig = lib.mkIf (site.assetProxy != "") ''
                  try_files $uri @production;
                '';
              };

              locations."@production" = lib.mkIf (site.assetProxy != "") {
                extraConfig = ''
                  resolver 8.8.8.8;
                  proxy_ssl_server_name on;
                  proxy_pass ${site.assetProxy};
                '';
              };
            };
          }) sites
        );
      };

      systemd.services = lib.mkMerge (
        lib.mapAttrsToList (name: site: {
          "${site.appName}-setupCache" = {
            description = "Creates object-cache.php in content dir for redis to work. Sets up nginx fastcgi cache";
            serviceConfig = {
              ExecStart = "${setupCache site}/bin/set-up-cache";
              Type = "simple";
            };
            wantedBy = [ "multi-user.target" ];
          };
        }) sites
      );
    };
}
