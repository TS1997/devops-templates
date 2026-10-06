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

    openUrl =
      url:
      if pkgs.stdenv.isDarwin then
        "open '${url}'"
      else
        "${pkgs.util-linux}/bin/setsid -f xdg-open '${url}' >/dev/null 2>&1 </dev/null";

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
