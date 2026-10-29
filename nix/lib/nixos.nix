{
  mkTokenScripts = import ./mkTokenScripts.nixos.nix;
  mkTofuScripts = import ./mkTofuScripts.nixos.nix;
  masterIdentity = import ./master-identity.nix;
  # Common secrets (JSON object), readable by people, master and CI
  sharedTokensFile = ../../secrets/build-pipeline/tokens.json.age;
}
