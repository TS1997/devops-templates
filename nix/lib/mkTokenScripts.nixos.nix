{ pkgs, lib }:
{
  # Shell expression for the age identity, e.g. ''"$AGE_IDENTITY"''
  ageKey,
  # Encrypted JSON object. A Nix path (copied to the store, still encrypted) or a
  # shell expression such as "$ROOT_DIR/secrets/tokens.json.age".
  tokensJsonAgeFilePath,
  # More encrypted JSON objects merged in before tokensJsonAgeFilePath (which
  # wins on conflicts), e.g. [ devops-templates.lib.sharedTokensFile ].
  extraTokensJsonAgeFilePaths ? [ ],
  sshKeyAgeFilePath ? null,
  # Format: "json_key:ENV_VAR_NAME". The json key may be a dotted path
  # (a.b.c). Non-string values (objects, numbers) are exported as compact JSON.
  variablePairs,
}:
let
  # Decrypts and merges the files, nothing is written to disk.
  #   eval "$(tokens)"       exports the variables into the calling shell
  #   tokens --github-env    masks the values and appends them to $GITHUB_ENV
  tokens = pkgs.writeShellApplication {
    name = "tokens";
    runtimeInputs = [
      pkgs.age
      pkgs.coreutils
      pkgs.jq
    ];
    text = ''
      mode="''${1:-}"
      case "$mode" in
        "") ;;
        --github-env) : "''${GITHUB_ENV:?tokens --github-env only works in GitHub Actions}" ;;
        *) echo "Usage: eval \"\$(tokens)\" | tokens --github-env" >&2; exit 2 ;;
      esac

      # tokensJsonAgeFilePath may refer to it, e.g. "$ROOT_DIR/secrets/..."
      ROOT_DIR="''${ROOT_DIR:-$(pwd)}"
      source_files=(${
        lib.concatMapStringsSep " " (path: ''"${path}"'') (
          extraTokensJsonAgeFilePaths ++ [ tokensJsonAgeFilePath ]
        )
      })
      variable_pairs=(${lib.escapeShellArgs variablePairs})

      tokens_json='{}'
      for source_file in "''${source_files[@]}"; do
        if ! file_json="$(age -d -i ${ageKey} "$source_file")"; then
          echo "tokens: could not decrypt $source_file" >&2
          exit 1
        fi
        # Deep merge via stdin, so no secret ends up in a process argument
        tokens_json="$(printf '%s\n%s\n' "$tokens_json" "$file_json" | jq -s '.[0] * .[1]')"
      done
      unset file_json

      for pair in "''${variable_pairs[@]}"; do
        json_key="''${pair%%:*}"
        env_var="''${pair##*:}"
        if [[ ! "$env_var" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
          echo "tokens: invalid variable name in pair '$pair'" >&2
          exit 1
        fi
        if ! jq -e --arg k "$json_key" 'getpath($k | split(".")) != null' <<<"$tokens_json" >/dev/null; then
          echo "tokens: '$json_key' not found, $env_var not set" >&2
          continue
        fi
        value="$(jq -r --arg k "$json_key" \
          'getpath($k | split(".")) | if type == "string" then . else tojson end' <<<"$tokens_json")"

        if [[ -z "$mode" ]]; then
          # %q quotes the value, so JSON, quotes and $ survive eval
          printf 'export %s=%q\n' "$env_var" "$value"
        else
          # Masks are per line, so mask every line of multi-line values
          while IFS= read -r line; do
            if [[ -n "$line" ]]; then
              echo "::add-mask::$line"
            fi
          done <<<"$value"
          delimiter="EOF_$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')"
          printf '%s<<%s\n%s\n%s\n' "$env_var" "$delimiter" "$value" "$delimiter" >> "$GITHUB_ENV"
        fi
      done
    '';
  };
in
{
  inherit tokens;

  # Prints $AGE_IDENTITY, or the ~/.ssh key listed in lib.masterIdentity.people
  selectAgeIdentity = pkgs.callPackage ../pkgs/select-age-identity.nix { };
}
// lib.optionalAttrs (sshKeyAgeFilePath != null) {
  addSshKey = pkgs.writeShellScriptBin "add-ssh-key" ''
    ssh_key=$(age --decrypt --identity ${ageKey} ${sshKeyAgeFilePath})
    ssh-add <(echo "$ssh_key")
  '';
}
