{
  lib,
  ...
}:
{
  options = {
    ts-transformer.enable = lib.mkEnableOption "Enable Laravel TypeScript Transformer watcher";
  };

  config = {
    ts-transformer.enable = lib.mkDefault true;
  };
}
