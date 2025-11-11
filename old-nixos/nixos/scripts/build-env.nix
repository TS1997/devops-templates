{ pkgs, ... }:
{
  name,
  environment,
  outputPath,
  secretsPath ? null,
}:
let
  envJson = builtins.toJSON environment;
in
pkgs.writeShellScript "build-env-${name}" ''
  tmpJson=$(mktemp)

  # Write the environment JSON to a file
  cat > "$tmpJson" <<'EOF'
  ${envJson}
  EOF

  if [ -f "${secretsPath}" ]; then
    # Merge: secrets override base environment
    merged=$(${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$tmpJson" "${secretsPath}")
  else
    merged=$(cat "$tmpJson")
  fi

  # Convert merged JSON -> .env
  ${pkgs.jq}/bin/jq -r 'to_entries | .[] | "\(.key)=\"\(.value)\""' <<<"$merged" > "${outputPath}"

  chmod 600 "${outputPath}"
  rm -f "$tmpJson"
''
