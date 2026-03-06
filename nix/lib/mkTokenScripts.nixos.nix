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
    RESET="\033[0m"

    if [[ -f "$ROOT_DIR/.tokens.sh" ]]; then
      echo -e "''${GREEN}.tokens.sh found, setting environment.''${RESET}"
      source "$ROOT_DIR/.tokens.sh"
    else
      echo -e "''${RED}.tokens.sh not found, run 'tokens''${RESET}"
    fi
  '';

  addSshKey = pkgs.writeShellScriptBin "add-ssh-key" ''
    ssh_key=$(age --decrypt --identity ${sshKeyAgeFilePath})
    ssh-add <(echo "$ssh_key")
  '';
}
