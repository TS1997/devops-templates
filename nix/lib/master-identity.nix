# Everyone listed here can decrypt every secret encrypted to the master identity:
# terraflake/deploy repo sources, devops-templates secrets/dev/* and anything
# else using lib.masterIdentity.
#
#   age.rekey = {
#     inherit (devops-templates.lib.masterIdentity) masterIdentities extraEncryptionPubkeys;
#     ...
#   };
#
# Format must be exactly "<type> <base64>" (no comment).
# After changing this list:
#   - here:       agenix update-masterkeys
#   - terraflake: nix flake update devops-templates, then
#                 tofuage update-masterkeys && tofuage rekey -a
# When removing someone, also rotate the actual secret values.
let
  # Break-glass backup: secrets/master.age (passphrase protected age key).
  # Never remove it, otherwise the next re-encryption drops the backup.
  masterPubkey = "age1d7x5yu2cw6rx7pcmv5u4v37lcs0dpzztshyczlfuc6z38j6a3dks3mlar6";

  people = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGavKgHzlln0r9APH/vyVQ5uGB+BXR6ybHoiAdLS+DY" # linus
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDObN2rJY9jwRZcOJniUtokZ4XMNN7A8MY5OaeIbhsyx" # Timmy
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzhVNFL+zJsluU3b8lIh2QvgqZ4PGS7O/kPkb5fN/UT6CCY/So78NSrPEB/GlUw+fGzNwxDCB54ylJDKQ+65nZ4qfROcTbpzVphS7Dv2wR+8pIc4cmsn9xMAJGLG0BRE7iE+4ar3FNzPhgKf9YGb/dwNso9lxufT0ssMT5tISj1Rwn+Welu5tqAHwfIBnoBRKgEQ9vYlwInzTtRSkfaS66JZw3vw8G0D7UI6AehwT3/b3rajI1kaIUe8MzDikqC/1ngkXtcA8WYJ3e9JNq9rnjx39AIQGipgaxF2a2MvOa4VSxzOBGYO5HUFB5Z7PQkCw01e1cxMG7rwu7EPTR/LtrUJRUFtC9nFnV1Fj9cTtIq8Jr8AUiCkC3FVcI0AXELuMMzkLwXlCf8839Qz2alTawzowRzT5+rQyqcSJkw0yr6G3UPqvydd7xbF6ZeImrmP+PfdZXmkZmbCa88x0u47awY8Hpv74zPyK+wFbNH7yP/PN+aW14QFTMEdQsxIoEt8cDJC1VdSclA2ZnFnbHdZQFcFRHWwcbv6N0ZrOoPjGxcZ+OgYbXHxDHx3XmL+6Y2R/Hsx1fZv06b0xuQ0v4fDjMJJYTy66Onq4P85nq/qh5DQ4EJgTKzUC5Lq0fDMX3MglfryZe7Wk4NbSpW5XsWpi5s7OK9iSBZOO5UdEGK+ns/w==" # Linus @ worklaptop
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRXn6YqUHJRklDD01x6CF5kLKSQZa2DZ6y1EFWr5FJRiZCRQ6PAksKT2B2z6fKqojZvn33iHWYrlhxeAcb4eq7G2uT7rSfTPzHIoHSgVUll8dFao6t5czCC+7CjN3KZg65r+GhMp5JFdJG+qzsyvVQF3TUY9J13wzQ6Yk7it3y8PeT5MTrKtc7N4pwJNZvh5EqpSz5icpQ1UNm0KT2ORwie6Vtt2GHEPNkgsjgVCStAICgtzOjk2/DOT5ZqH/TVY9c09sAT/5NcQYf/hF8Yp82w54QVM0VWwwdbCV/KiNMEGhBnD6TDRqVg+CKTUP6AUSRHIIkARyrA2EPRljXvgMBzB698W0fYVYHDMveOpMzPmu5Sgvg0J4F+15NegVC+botyxvrSzMYRRZegb+mgKCtrMyk56LCHfMGi8v98VpAfyBc7bXi17LPxHgNuRazIW95npL7npTafCwzxaAfc3fLSKoH5kSkBoHomBfjoXsmtrkqiNvNEZP2BAPuw0o+J0s=" # Fredrik
  ];
in
{
  inherit people masterPubkey;

  # A single decryption identity: whatever key $AGE_IDENTITY points to
  # (see select-age-identity).
  masterIdentities = [
    {
      identity = "\"$AGE_IDENTITY\"";
      pubkey = masterPubkey;
    }
  ];

  # Secrets are encrypted to masterPubkey plus everyone in `people`.
  extraEncryptionPubkeys = people;
}
