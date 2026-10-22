{
  config,
  lib,
  pkgs,
  util,
  ...
}:
let
  inherit (lib) types mkOption mkEnableOption;
in
{
  options = {
    enable = mkEnableOption "Enable bravoadmin site.";

    domain = mkOption {
      type = types.str;
      description = "The domain name of the site.";
    };

    extraDomains = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional domain names for the site.";
    };

    workingDir = mkOption {
      type = types.str;
      default = util.values.devenvRoot;
      description = "The working directory of the site. Shared repos (common, bravoadmin, ...) are expected next to it.";
    };

    webRoot = mkOption {
      type = types.str;
      default = "${config.workingDir}/public";
      description = "The web root directory of the site.";
    };

    port = mkOption {
      type = types.int;
      default = 8080;
      description = "The port that the site will be served on.";
    };

    sslPort = mkOption {
      type = types.int;
      default = 5443;
      description = "The SSL port that the site will be served on.";
    };

    enableSsl = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable SSL for the site.";
    };

    charset = mkOption {
      type = types.str;
      default = "ISO-8859-1";
      description = "Charset for PHP (default_charset) and nginx responses.";
    };

    maxExecutionTime = mkOption {
      type = types.int;
      default = 300;
      description = "The maximum execution time for PHP scripts in seconds.";
    };

    productionUrl = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "https://www.example.se";
      description = "Production URL to proxy missing uploaded files from (see assetFallbackPaths).";
    };

    assetFallbackPaths = mkOption {
      type = types.listOf types.str;
      default = [
        "static/webimages"
        "static/webfiles"
      ];
      description = "Web root relative paths whose missing files are fetched from productionUrl.";
    };

    requiredRepos = mkOption {
      type = types.listOf types.str;
      default = [
        "config"
        "library"
        "common"
        "bravoadmin"
        "crm"
      ];
      description = "Repositories that must be cloned next to the working directory. Missing ones are cloned when entering the shell.";
    };

    repoBaseUrl = mkOption {
      type = types.str;
      default = "git@github.com:bravomedia";
      description = "Base git URL used to clone missing repositories.";
    };

    crm = {
      enable = mkEnableOption "Serve the crm repository under /crm/." // {
        default = true;
      };

      dir = mkOption {
        type = types.str;
        default = "${dirOf config.workingDir}/crm";
        description = "Path to the crm repository.";
      };
    };

    php = {
      package = mkOption {
        type = types.package;
        default = pkgs.php84;
        description = "The PHP package to use.";
      };

      extensions = mkOption {
        type = with types; functionTo (listOf anything);
        default = _: [ ];
        description = "Extra PHP extensions to include.";
        example = lib.literalExpression "extensions: [ extensions.redis ]";
      };

      ini = mkOption {
        type = types.lines;
        description = "php.ini directives for both the CLI and PHP-FPM.";
      };

      settings = mkOption {
        type =
          with types;
          attrsOf (oneOf [
            str
            int
            bool
          ]);
        description = "PHP-FPM pool settings.";
      };
    };

    database = {
      name = mkOption {
        type = types.str;
        description = "The site database name (BRAVO_DB_NAME).";
      };

      crmName = mkOption {
        type = types.str;
        default = "bravoadmin";
        description = "The bravoadmin/crm database name (BRAVO_CRM_DB_NAME).";
      };

      # Same local credentials as bravo-dev, defaults in common/ expect these
      user = mkOption {
        type = types.str;
        default = "bravoadmin";
        description = "The database user.";
      };

      password = mkOption {
        type = types.str;
        default = "12janne34";
        description = "The local database password.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.mariadb;
        description = "The MySQL/MariaDB package to use.";
      };

      admin.enable = mkEnableOption "Enable phpMyAdmin." // {
        default = true;
      };

      settings = mkOption {
        type =
          with types;
          attrsOf (oneOf [
            str
            int
            bool
          ]);
        description = "Extra mysqld settings.";
      };
    };

    mailpit.enable = mkEnableOption "Enable Mailpit and route PHP mail() to it." // {
      default = true;
    };

    env = mkOption {
      type =
        with types;
        attrsOf (
          nullOr (oneOf [
            str
            bool
            int
          ])
        );
      default = { };
      description = "Environment variables for the site, merged over the BRAVO_* defaults.";
    };
  };

  config = {
    php.ini = lib.mkBefore ''
      short_open_tag = On
      error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
      log_errors = On
      memory_limit = 2G
      max_execution_time = ${toString config.maxExecutionTime}
      max_input_time = 600
      max_input_vars = 10000
      upload_max_filesize = 1G
      post_max_size = 2G
    '';

    php.settings = lib.mapAttrs (_: lib.mkDefault) {
      "clear_env" = "no";
      "pm" = "dynamic";
      "pm.max_children" = 10;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 5;
      "request_terminate_timeout" = config.maxExecutionTime + 60;
      "php_flag[display_errors]" = true;
      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
    };

    database.settings = lib.mapAttrs (_: lib.mkDefault) {
      sql_mode = "NO_ENGINE_SUBSTITUTION,ALLOW_INVALID_DATES";
      max_allowed_packet = "128M";
      # MySQL 5.7 defaults: PHP connects as latin1 and gets the stored UTF-8 bytes unconverted
      character-set-server = "latin1";
      collation-server = "latin1_swedish_ci";
    };
  };
}
