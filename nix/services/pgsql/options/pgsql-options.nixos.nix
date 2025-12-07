{
  lib,
  ...
}:
{
  options = {
    databases = lib.mkOption {
      # Use lib.types.submodule here instead of util.submodule to avoid circular dependency
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            extensions = lib.mkOption {
              type = with lib.types; coercedTo (listOf path) (path: _ignorePg: path) (functionTo (listOf path));
              default = _: [ ];
              example = lib.literalExpression "ps: with ps; [ postgis pg_repack ]";
            };
          };
        }
      );
    };
  };

  config = {
    socket = "/run/postgresql";
  };
}
