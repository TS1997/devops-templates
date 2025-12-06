values:
{
  lib,
  pkgs,
  stdenv,
  ...
}:
let
  util = {
    inherit values;

    submodule =
      module:
      lib.types.submodule (
        lib.recursiveUpdate module {
          config._module.args = { inherit pkgs util; };
        }
      );
  };
in
{
  _module.args.util = util;
}
