{ self, agenix-rekey }:
agenix-rekey.configure {
  userFlake = self;
  nixosConfigurations.devSecrets.config.age = {
    rekey = {
      inherit (self.lib.masterIdentity) masterIdentities;
      # CI reads the common secrets too (GitHub secret CI_AGE_KEY)
      extraEncryptionPubkeys = self.lib.masterIdentity.people ++ [ self.lib.masterIdentity.ciPubkey ];
    };
    secrets.tokens.rekeyFile = self.lib.sharedTokensFile;
  };
  agePackage = p: p.age;
}
