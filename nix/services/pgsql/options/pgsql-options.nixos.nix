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
              type =
                with lib.types;
                coercedTo
                  (listOf (oneOf [
                    path
                    str
                  ]))
                  (items: _ignorePg: items)
                  (
                    functionTo (
                      listOf (oneOf [
                        path
                        str
                      ])
                    )
                  );
              default = _: [ ];
              example = lib.literalExpression "ps: with ps; [ postgis \"postgis_raster\" pg_repack ]";
              description = "PostgreSQL extensions to enable. Use package paths for installable extensions and strings for SQL extension names already provided by installed packages.";
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
