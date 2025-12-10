{
  env,
  envSecretsFile ? null,
  lib,
  pkgs,
  workingDir,
  ...
}:
lib.stringAfter [ "agenix" ] ''
  # Start with regular env vars
  cat > ${workingDir}/.env << 'EOF'
  ${lib.concatStringsSep "\n" (
    lib.mapAttrsToList (envName: value: "${envName}=${toString value}") env
  )}
  EOF

  # Merge secrets from agenix file if it exists
  ${lib.optionalString (envSecretsFile != null) ''
    if [ -f ${envSecretsFile} ]; then
      cat ${envSecretsFile} ${workingDir}/.env | \
        ${pkgs.gawk}/bin/awk -F= '!seen[$1]++ {print}' > ${workingDir}/.env.tmp
      mv ${workingDir}/.env.tmp ${workingDir}/.env
    fi
  ''}

  chmod 600 ${workingDir}/.env
''
