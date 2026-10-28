# Flake Templates

## Usage

To create a new project in the directory `new-project` from the WordPress template:

```sh
mkdir new-project
cd new-project
nix flake init --refresh --template "github:ts1997/devops-templates?ref=master#wp-flake"
```

To create a Braavos base WordPress project:

```sh
mkdir new-project
cd new-project
nix flake init --refresh --template "github:ts1997/devops-templates?ref=master#wp-base"
```

To create a new Laravel site:

```sh
nix run "github:ts1997/devops-templates?ref=master#laravel-site"
```

To create a new Laravel package:

```sh
nix run "github:ts1997/devops-templates?ref=master#laravel-package"
```

## Shared secrets

The `people` list and `masterPubkey` (the passphrase protected break-glass key `secrets/master.age`) in `nix/lib/master-identity.nix` are the recipients for all team secrets. Deploy repos such as terraflake use them through `devops-templates.lib.masterIdentity` and do the host rekeying themselves.

Shared dev secrets live in `secrets/dev/tokens.json.age` (a JSON object), managed with agenix-rekey like in terraflake (`nix/lib/agenix-rekey.nix`). In this repo's dev shell (`direnv allow`, or `nix develop`):

```sh
agenix edit secrets/dev/tokens.json.age   # edit / create
agenix view secrets/dev/tokens.json.age   # print
agenix update-masterkeys                  # re-encrypt everything to the current list
```

The dev shell sets `AGE_IDENTITY` to the first `~/.ssh/*.pub` key listed in `people` (`select-age-identity`; set `AGE_IDENTITY` yourself to override).

A project exports values from it when entering the devenv shell (decrypted with your `~/.ssh` key, or `$AGE_IDENTITY`, into `.devenv/state/tokens.sh`):

```nix
services.ts1997.tokens.variables = [ "composer_auth:COMPOSER_AUTH" ];
```

After changing `nix/lib/master-identity.nix`, run `agenix update-masterkeys`, push, and run `nix flake update devops-templates` followed by `tofuage update-masterkeys && tofuage rekey -a` in terraflake.
