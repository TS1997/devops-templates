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
    if lib.isBool value then
      (if value then "true" else "false")
    else if (lib.isString value && lib.stringLength value > 0) then
      "\"${value}\""
    else
      toString value;

  envFile = "${siteCfg.workingDir}/.env";
in
lib.stringAfter [ "agenix" ] ''
  # Start with regular env vars
  cat > ${envFile} << 'EOF'
  ${lib.concatStringsSep "\n" (
    lib.mapAttrsToList (envName: value: "${envName}=${mkValue value}") (defaultEnv // siteCfg.env)
  )}
  EOF

  # Merge secrets from agenix file if it exists
  ${lib.optionalString (siteCfg.envSecretsFile != null) ''
    if [ -f ${siteCfg.envSecretsFile} ]; then
      cat ${siteCfg.envSecretsFile} ${envFile} | \
        ${pkgs.gawk}/bin/awk -F= '!seen[$1]++ {print}' > ${envFile}.tmp
      mv ${envFile}.tmp ${envFile}
    fi
  ''}

  chown ${siteCfg.user}:${siteCfg.user} ${envFile}
  chmod 600 ${envFile}
''
