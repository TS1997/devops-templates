{
  lib,
  pkgs,
  defaultEnv,
  siteCfg,
  ...
}:
let
  mkValue =
    value:
    if (lib.isString value && lib.stringLength value > 0) then "\"${value}\"" else toString value;
in
lib.stringAfter [ "agenix" ] ''
  # Start with regular env vars
  cat > ${siteCfg.workingDir}/.env << 'EOF'
  ${lib.concatStringsSep "\n" (
    lib.mapAttrsToList (envName: value: "${envName}=${mkValue value}") (defaultEnv // siteCfg.env)
  )}
  EOF

  # Merge secrets from agenix file if it exists
  ${lib.optionalString (siteCfg.envSecretsFile != null) ''
    if [ -f ${siteCfg.envSecretsFile} ]; then
      cat ${siteCfg.envSecretsFile} ${siteCfg.workingDir}/.env | \
        ${pkgs.gawk}/bin/awk -F= '!seen[$1]++ {print}' > ${siteCfg.workingDir}/.env.tmp
      mv ${siteCfg.workingDir}/.env.tmp ${siteCfg.workingDir}/.env
    fi
  ''}

  chown ${siteCfg.user}:${siteCfg.user} ${siteCfg.workingDir}/.env
  chmod 600 ${siteCfg.workingDir}/.env
''
