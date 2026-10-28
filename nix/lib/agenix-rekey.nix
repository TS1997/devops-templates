# Same flow as terraflake: `agenix edit`, `agenix view`, and
# `agenix update-masterkeys` after changing nix/lib/master-identity.nix.
{ self, agenix-rekey }:
agenix-rekey.configure {
  userFlake = self;
  nixosConfigurations.devSecrets.config.age = {
    rekey = { inherit (self.lib.masterIdentity) masterIdentities extraEncryptionPubkeys; };
    secrets.tokens.rekeyFile = ../../secrets/dev/tokens.json.age;
  };
  agePackage = p: p.age;
}
