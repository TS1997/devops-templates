{ lib, ... }:
{
  imports = [ ./phpfpm-package-options.base.nix ];

  options = {
    extraConfig = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      description = "Global PHP-FPM configuration.";
    };

    phpEnv = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Environment variables for the PHP-FPM pool.";
    };

    phpOptions = lib.mkOption {
      type = lib.types.lines;
      default = ''
        error_reporting = -1
        log_errors = On
        log_errors_max_len = 0
        upload_max_filesize = 50M
        post_max_size = 50M
        memory_limit = 512M
        max_execution_time = 300
      '';
      description = "PHP options for the PHP-FPM pool.";
    };

    settings = lib.mkOption {
      type =
        with lib.types;
        attrsOf (oneOf [
          str
          int
          bool
        ]);
      default = {
        "clear_env" = "no";
        "pm" = "dynamic";
        "pm.max_children" = 10;
        "pm.start_servers" = 10;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 10;
        "request_terminate_timeout" = 360;
        "php_flag[display_errors]" = true;
        "php_admin_flag[log_errors]" = true;
        "php_value[memory_limit]" = "512M";
        "catch_workers_output" = true;
        "php_value[upload_max_filesize]" = "64M";
        "php_value[post_max_size]" = "64M";
      };
      description = "Additional PHP-FPM pool settings.";
    };
  };
}
