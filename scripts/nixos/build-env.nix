{
  pkgs,
  name,
  environment,
  secretsPath ? null,
  outputPath,
  ...
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

  # Convert merged JSON -> .env with conditional quoting
  ${pkgs.jq}/bin/jq -r '
    to_entries | .[] | 
    if (.value | type) == "number" or (.value | type) == "null" then
      "\(.key)=\(.value)"
    elif (.value | type) == "string" and (.value | test("^[a-zA-Z0-9_/.:-]+$")) then
      "\(.key)=\(.value)"
    else
      "\(.key)=\"\(.value)\""
    end
  ' <<<"$merged" > "${outputPath}"

  chmod 600 "${outputPath}"
  rm -f "$tmpJson"
''
