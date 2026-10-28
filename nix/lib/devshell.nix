{ pkgs, agenix-rekey }:
pkgs.mkShell {
  packages = [
    pkgs.age
    agenix-rekey
    (pkgs.callPackage ../pkgs/select-age-identity.nix { })
  ];
  shellHook = ''
    if AGE_IDENTITY="$(select-age-identity)"; then
      export AGE_IDENTITY
      echo "Age identity: $AGE_IDENTITY"
    fi
  '';
}
