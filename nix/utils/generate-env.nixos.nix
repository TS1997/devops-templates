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

  # Sites deployed from a read-only package (siteCfg.package != null) can't
  # have their .env read from base_path(), since that now resolves inside
  # the Nix store. Write a plain "env" file in workingDir instead, meant to
  # be wired up as a systemd/phpfpm EnvironmentFile, rather than a
  # Dotenv-loaded .env.
  envFile =
    if (siteCfg.package or null) != null then
      "${siteCfg.workingDir}/env"
    else
      "${siteCfg.workingDir}/.env";
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
