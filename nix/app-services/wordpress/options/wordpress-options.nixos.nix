{ config, lib, ... }:
{
  options = {
    uploadsDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.webRoot}/content/uploads";
      description = "Absolute path to the WordPress uploads directory. Must match the path set in the site's .env (e.g. via UPLOADS_PATH or a custom wp-config value).";
    };

    opensearch.syncSchedule = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "daily";
      example = "*-*-* 03:00:00";
      description = "systemd OnCalendar expression for a full ElasticPress sync. Missing indices are always created shortly after boot/deploy; set to null to skip the scheduled sync.";
    };
  };

  config = {
    backup.paths = lib.mkDefault [ config.uploadsDir ];
  };
}
