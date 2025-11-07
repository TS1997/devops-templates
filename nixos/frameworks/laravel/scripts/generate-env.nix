{
  lib,
  pkgs,
}:
name: siteCfg:
let
  baseEnv = import ../settings/base-env.nix { inherit name siteCfg; };
  mergedEnv = baseEnv // siteCfg.environment;

  mkFilterEmpty =
    env: lib.filterAttrs (name: value: value != null && value != "" && value != "null") env;

  # Quote and escape all values for php-fpm config
  quote =
    v:
    let
      s = builtins.toString v;
      esc = builtins.replaceStrings [ "\\" "\"" "\n" "\r" "\t" ] [ "\\\\" "\\\"" "\\n" "\\r" "\\t" ] s;
    in
    ''"${esc}"'';
in
lib.mapAttrs (_: v: quote v) (mkFilterEmpty mergedEnv)
