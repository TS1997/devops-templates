{ config, lib, ... }:
{
  options = {
    uploadsDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.webRoot}/content/uploads";
      description = "Absolute path to the WordPress uploads directory. Must match the path set in the site's .env (e.g. via UPLOADS_PATH or a custom wp-config value).";
    };
  };
}
