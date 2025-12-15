{ lib, ... }:
{
  options = {
    composer.install.enable = lib.mkEnableOption "Enable automatic Composer installation in development shell.";
  };
}
