{ pkgs, lib }:
{
  ageKey,
  tokensJsonAgeFilePath,
  sshKeyAgeFilePath,
  variablePairs,
}:
let
  pairsStr = lib.concatMapStringsSep "\n      " (p: ''"${p}"'') variablePairs;
in
{
  tokens = pkgs.writeShellScriptBin "tokens" ''
    ROOT_DIR="$(pwd)"
    tokens_json=$(age -d -i ${ageKey} ${tokensJsonAgeFilePath})

    # Format: "json_key:ENV_VAR_NAME"
    # The selector in the json file comes first
    # and then the actual variable name to export
    variable_pairs_to_export=(
      ${pairsStr}
    )

    # Overwrite the file each time this is run
    > "$ROOT_DIR/.tokens.sh"

    # Write the source file mtimes as a comment header for staleness checks
    echo "# source_mtime=$(stat -c %Y ${tokensJsonAgeFilePath} 2>/dev/null || echo 0)" >> "$ROOT_DIR/.tokens.sh"

    for pair in "''${variable_pairs_to_export[@]}"; do
      json_key="''${pair%%:*}"
      env_var="''${pair##*:}"
      value=$(jq -r ".$json_key // \"\"" <<<"$tokens_json")
      echo "export $env_var=\"$value\"" >> "$ROOT_DIR/.tokens.sh"
    done

    echo "Tokens exported to .tokens.sh"
  '';

  setEnvironment = pkgs.writeShellScriptBin "set-environment" ''
    ROOT_DIR="$(pwd)"
    GREEN="\033[0;32m"
    RED="\033[0;31m"
    YELLOW="\033[0;33m"
    RESET="\033[0m"

    _tokens_is_stale() {
      local tokens_file="$ROOT_DIR/.tokens.sh"

      # No file at all — stale
      [[ ! -f "$tokens_file" ]] && return 0

      local recorded_mtime
      recorded_mtime=$(grep '^# source_mtime=' "$tokens_file" | cut -d= -f2)

      # No mtime header (old format) — stale
      [[ -z "$recorded_mtime" ]] && return 0

      local current_mtime
      current_mtime=$(stat -c %Y ${tokensJsonAgeFilePath} 2>/dev/null || echo 0)

      [[ "$current_mtime" != "$recorded_mtime" ]] && return 0

      return 1
    }

    if _tokens_is_stale; then
      echo -e "''${YELLOW}.tokens.sh is missing or outdated, regenerating...''${RESET}"
      tokens
    fi

    if [[ -f "$ROOT_DIR/.tokens.sh" ]]; then
      echo -e "''${GREEN}.tokens.sh found, setting environment.''${RESET}"
      source "$ROOT_DIR/.tokens.sh"
    else
      echo -e "''${RED}.tokens.sh not found and could not be generated.''${RESET}"
    fi
  '';

  addSshKey = pkgs.writeShellScriptBin "add-ssh-key" ''
    ssh_key=$(age --decrypt --identity ${ageKey} ${sshKeyAgeFilePath})
    ssh-add <(echo "$ssh_key")
  '';
}
