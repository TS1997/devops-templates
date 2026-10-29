{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ts1997.tokens;
  masterIdentity = import ../lib/master-identity.nix;

  sharedFile =
    if builtins.pathExists cfg.file then
      cfg.file
    else
      throw "services.ts1997.tokens.file does not exist: ${toString cfg.file}";

  # Read from the working tree, so tokens-edit changes apply without a rebuild
  projectFilePath = "$DEVENV_ROOT/${cfg.projectFile}";

  tokenScripts = import ../lib/mkTokenScripts.nixos.nix { inherit pkgs lib; } (
    {
      ageKey = ''"$AGE_IDENTITY"'';
      variablePairs = cfg.variables;
      # .devenv is gitignored in every project
      tokensFile = ''"$DEVENV_STATE/tokens.sh"'';
    }
    # The project file wins over the shared one on conflicting keys
    // (
      if cfg.projectFile == null then
        { tokensJsonAgeFilePath = sharedFile; }
      else
        {
          tokensJsonAgeFilePath = projectFilePath;
          extraTokensJsonAgeFilePaths = [ sharedFile ];
        }
    )
  );

  # Same recipients as the shared file: people, the master key and CI
  recipients = pkgs.writeText "tokens-recipients" (
    lib.concatLines (
      masterIdentity.people
      ++ [
        masterIdentity.masterPubkey
        masterIdentity.ciPubkey
      ]
    )
  );

  tokensEdit = pkgs.writeShellApplication {
    name = "tokens-edit";
    runtimeInputs = [
      pkgs.age
      pkgs.jq
      pkgs.coreutils
      pkgs.gnugrep
      tokenScripts.selectAgeIdentity
    ];
    text = ''
      # Creates or edits ${cfg.projectFile} in $EDITOR. Saving re-encrypts to the
      # current devops-templates recipients, so run it after people change too.
      umask 077
      file="${projectFilePath}"
      work_dir="$(mktemp -d)"
      trap 'rm -rf "$work_dir"' EXIT
      plain="$work_dir/tokens.json"

      if [[ -f "$file" ]]; then
        identity="$(select-age-identity)"
        age -d -i "$identity" -o "$plain" "$file"
      else
        echo '{}' > "$plain"
      fi

      read -ra editor <<< "''${VISUAL:-''${EDITOR:-vi}}"
      "''${editor[@]}" "$plain"

      if ! jq -e 'type == "object"' "$plain" > /dev/null; then
        echo "tokens-edit: not a JSON object, $file left unchanged." >&2
        exit 1
      fi

      mkdir -p "$(dirname "$file")"
      encrypted="$(mktemp "$file.XXXXXX")"
      age -e -R ${recipients} -o "$encrypted" "$plain"
      chmod 644 "$encrypted"
      mv "$encrypted" "$file"
      echo "Saved $file ($(grep -c . ${recipients}) recipients). Commit it."
    '';
  };
in
{
  options.services.ts1997.tokens = {
    variables = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "composer_auth:COMPOSER_AUTH" ];
      description = ''
        Shared dev secrets to export when entering the shell, as
        "json_key:ENV_VAR_NAME". Values come from `file`, which is encrypted to
        everyone in devops-templates nix/lib/master-identity.nix, and are decrypted with
        your ssh key (see select-age-identity) into .devenv/state/tokens.sh.
        Edit the secrets in the devops-templates dev shell with
        `agenix edit secrets/build-pipeline/tokens.json.age`.
      '';
    };

    file = lib.mkOption {
      type = lib.types.path;
      default = ../../secrets/build-pipeline/tokens.json.age;
      description = "age encrypted JSON object the variables are read from.";
    };

    projectFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "secrets/tokens.json.age";
      description = ''
        Project-specific age encrypted JSON object, relative to the project root
        and committed there. Merged over `file`, so its keys win. Create and
        edit it with `tokens-edit`.
      '';
    };
  };

  config = lib.mkIf (cfg.variables != [ ]) {
    packages = [
      tokenScripts.selectAgeIdentity
      tokenScripts.tokens
    ]
    ++ lib.optional (cfg.projectFile != null) tokensEdit;

    # Before anything else in enterShell (e.g. composer install) needs them
    enterShell = lib.mkBefore ''
      if _age_identity="$(${tokenScripts.selectAgeIdentity}/bin/select-age-identity)"; then
        export AGE_IDENTITY="$_age_identity"
        source ${tokenScripts.setEnvironment}/bin/set-environment
      else
        echo "Skipping shared tokens (${lib.concatStringsSep ", " cfg.variables})." >&2
      fi
      unset _age_identity
    '';
  };
}
