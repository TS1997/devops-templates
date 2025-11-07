{
  config,
  lib,
  pkgs,
  ...
}:
name: siteCfg:
let
  envContent = pkgs.writeText "laravel-env-${name}" (
    import ../settings/base-env.nix { inherit name siteCfg; }
  );
in
pkgs.writeShellScript "generate-env-${name}" ''
  cat ${envContent} > ${siteCfg.workingDir}/.env
  cat ${config.age.secrets."${name}-env".path} >> ${siteCfg.workingDir}/.env
  for envVar in ${lib.escapeShellArgs siteCfg.extraEnvs}; do
    echo "$envVar" >> ${siteCfg.workingDir}/.env
  done
''
