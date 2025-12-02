values:
{ lib, pkgs, ... }:
let
  util = {
    submoduleWithPkgs =
      module:
      lib.types.submodule (
        lib.recursiveUpdate module {
          config._module.args = { inherit pkgs util; };
        }
      );

    inherit values;
  };
in
{
  _module.args.util = util;
}
