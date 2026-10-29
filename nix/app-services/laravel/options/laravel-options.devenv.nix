{
  lib,
  ...
}:
{
  options = {
    generate-types.enable = lib.mkEnableOption "Enable automatic TypeScript type generation.";
  };

  config = {
    generate-types.enable = lib.mkDefault true;
    composer.auth.enable = lib.mkDefault true;
    nodejs.auth.enable = lib.mkDefault true;
  };
}
