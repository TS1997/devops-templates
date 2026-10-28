{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ts1997.tokens;

  tokenScripts = import ../lib/mkTokenScripts.nixos.nix { inherit pkgs lib; } {
    ageKey = ''"$AGE_IDENTITY"'';
    tokensJsonAgeFilePath =
      if builtins.pathExists cfg.file then
        cfg.file
      else
        throw "services.ts1997.tokens.file does not exist: ${toString cfg.file}";
    variablePairs = cfg.variables;
    # .devenv is gitignored in every project
    tokensFile = ''"$DEVENV_STATE/tokens.sh"'';
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
        `agenix edit secrets/dev/tokens.json.age`.
      '';
    };

    file = lib.mkOption {
      type = lib.types.path;
      default = ../../secrets/dev/tokens.json.age;
      description = "age encrypted JSON object the variables are read from.";
    };
  };

  config = lib.mkIf (cfg.variables != [ ]) {
    packages = [
      tokenScripts.selectAgeIdentity
      tokenScripts.tokens
    ];

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
