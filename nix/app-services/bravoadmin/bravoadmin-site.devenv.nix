{
  config,
  lib,
  util,
  ...
}:
let
  name = "web";
  siteCfg = config.services.ts1997.bravoadminSite;
  db = siteCfg.database;
  phpSocket = config.languages.php.fpm.pools.${name}.socket;
  mailpitCfg = config.services.ts1997.mailpit;

  # Applied to both the CLI package and the FPM pool (pool options are appended last)
  phpIni = ''
    ${siteCfg.php.ini}
    mysqli.default_socket = ${util.values.mysqlSocket}
    pdo_mysql.default_socket = ${util.values.mysqlSocket}
    ${lib.optionalString siteCfg.mailpit.enable ''
      sendmail_path = "${mailpitCfg.package}/bin/mailpit sendmail -S ${mailpitCfg.smtp.host}:${toString config.processes.mailpit.ports.smtp.value}"
    ''}
  '';

  reposDir = dirOf siteCfg.workingDir;

  defaultEnv = import ./config/default-env.nix { inherit siteCfg util; };

  locations = import ./config/nginx-locations.nix {
    inherit
      config
      lib
      siteCfg
      phpSocket
      ;
  };
in
{
  options.services.ts1997.bravoadminSite = lib.mkOption {
    type = util.submodule {
      imports = [ ./options/bravoadmin-options.devenv.nix ];
    };
    default = { };
    description = "Bravoadmin (Yii) site configuration";
  };

  config = lib.mkIf siteCfg.enable {
    env = defaultEnv // siteCfg.env;

    services.ts1997.phpfpm = {
      enable = true;
      basePackage = siteCfg.php.package;
      extensions = siteCfg.php.extensions;
      ini = phpIni;
      pools.${name} = {
        basePackage = siteCfg.php.package;
        extensions = siteCfg.php.extensions;
        ini = phpIni;
        maxExecutionTime = siteCfg.maxExecutionTime;
        phpOptions = phpIni + ''
          default_charset = "${siteCfg.charset}"
        '';
        settings = siteCfg.php.settings;
      };
    };

    services.ts1997.nginx = {
      enable = true;
      virtualHosts.${name} = {
        serverName = siteCfg.domain;
        serverAliases = siteCfg.extraDomains;
        root = siteCfg.webRoot;
        port = siteCfg.port;
        sslPort = siteCfg.sslPort;
        enableSsl = siteCfg.enableSsl;
        extraConfig = ''
          index index.php index.html;
          charset ${lib.toLower siteCfg.charset};
          client_max_body_size 1g;

          # Same as the trailing slash redirect in public/.htaccess
          if (!-d $request_filename) {
            rewrite ^/((?!crm/).+)/$ /$1 permanent;
          }
        '';
        inherit locations;
      };
    };

    services.ts1997.mysql = {
      enable = true;
      package = db.package;
      databases =
        map
          (dbName: {
            name = dbName;
            inherit (db) user password;
          })
          (
            lib.unique [
              db.name
              db.crmName
            ]
          );
      phpMyAdmin.enable = db.admin.enable;
    };

    services.mysql.settings.mysqld = db.settings;

    services.ts1997.mailpit.enable = siteCfg.mailpit.enable;

    enterShell = ''
      for repo in ${lib.concatStringsSep " " siteCfg.requiredRepos}; do
        if [ ! -d "${reposDir}/$repo" ]; then
          git clone --recursive "${siteCfg.repoBaseUrl}/$repo.git" "${reposDir}/$repo"
        fi
      done
    '';
  };
}
