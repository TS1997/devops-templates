{
  lib,
  writeShellApplication,
}:
let
  inherit (import ../lib/master-identity.nix) people;
in
writeShellApplication {
  name = "select-age-identity";
  text = ''
    # Prints the age identity used to decrypt master identity secrets:
    # $AGE_IDENTITY when set, otherwise the first private key in ~/.ssh whose
    # public key is in devops-templates lib.masterIdentity.people.
    # Usage: AGE_IDENTITY="$(select-age-identity)" && export AGE_IDENTITY
    if [[ -n "''${AGE_IDENTITY:-}" ]]; then
      printf '%s\n' "$AGE_IDENTITY"
      exit 0
    fi

    people=(${lib.escapeShellArgs people})

    for pub in "$HOME"/.ssh/*.pub; do
      key="''${pub%.pub}"
      [[ -e "$pub" && -r "$key" ]] || continue
      read -r ssh_key_type key_base64 _ < "$pub" || true
      for person in "''${people[@]}"; do
        if [[ "$ssh_key_type $key_base64" == "$person" ]]; then
          printf '%s\n' "$key"
          exit 0
        fi
      done
    done

    echo "select-age-identity: no ~/.ssh key is listed in devops-templates nix/lib/master-identity.nix." >&2
    echo "Set AGE_IDENTITY to your private key, or get your public key added there." >&2
    exit 1
  '';
}
