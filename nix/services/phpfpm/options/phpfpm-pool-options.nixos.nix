{ lib, name, ... }:
{
  options = {
    user = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "The user that the PHP-FPM pool will run as.";
    };
  };
}
