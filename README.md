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

Shared dev secrets live in `secrets/build-pipeline/tokens.json.age` (a JSON object), managed with agenix-rekey like in terraflake (`nix/lib/agenix-rekey.nix`). In this repo's dev shell (`direnv allow`, or `nix develop`):

```sh
agenix edit secrets/build-pipeline/tokens.json.age   # edit / create
agenix view secrets/build-pipeline/tokens.json.age   # print
agenix update-masterkeys                             # re-encrypt everything to the current list
```

The dev shell sets `AGE_IDENTITY` to the first `~/.ssh/*.pub` key listed in `people` (`select-age-identity`; set `AGE_IDENTITY` yourself to override).

A project exports values from it when entering the devenv shell (decrypted with your `~/.ssh` key, or `$AGE_IDENTITY`, into `.devenv/state/tokens.sh`):

```nix
services.ts1997.tokens.variables = [ "composer_auth:COMPOSER_AUTH" ];
```

App options set these by default:

| Option                 | Exports                               | Default                                        |
| ---------------------- | ------------------------------------- | ---------------------------------------------- |
| `composer.auth.enable` | `composer_auth` → `COMPOSER_AUTH`     | on for Laravel site/package, off for WordPress |
| `nodejs.auth.enable`   | `bravo_npm_token` → `BRAVO_NPM_TOKEN` | on for Laravel site/package, off for WordPress |

e.g. `services.ts1997.laravelSite.nodejs.auth.enable = false;`. The npm token is read by the project's committed `.npmrc`:

```ini
@bravomedia:registry=https://npmregistry.bravomedia.se/
//npmregistry.bravomedia.se/:_authToken=${BRAVO_NPM_TOKEN}
```

### Project secrets

A project can keep its own secrets in a committed, encrypted JSON file:

```nix
services.ts1997.tokens = {
  projectFile = "secrets/tokens.json.age"; # relative to the project root
  variables = [ "fontawesome_token:FONTAWESOME_TOKEN" ];
};
```

Run `tokens-edit` in the project's shell to create or edit it. It encrypts to the same recipients as the shared file (`people`, `masterPubkey`, `ciPubkey`); run it again and save after `people` changes.

The project file is deep-merged over the shared file, so the project wins only on identical paths. For example, a project `composer_auth` with another host keeps the shared `packages.bravomedia.se` entry and `COMPOSER_AUTH` contains both:

```json
{
  "composer_auth": {
    "http-basic": { "repo.example.com": { "username": "…", "password": "…" } }
  }
}
```

Use the same key (`composer_auth`) to get this merge. A different key mapped to the same variable replaces it instead.

### CI and terraflake

The shared file is also encrypted to the CI key (`ciPubkey`, GitHub secret `CI_AGE_KEY`):

- `laravel-deploy.yml` / `wordpress-deploy.yml` / `laravel-publish-types.yml`: require `CI_AGE_KEY`. `devenv-setup` then exports the same variables in CI and masks them. There is no separate `AUTH_JSON` secret; `COMPOSER_AUTH` comes from `composer_auth`.
- terraflake: `mkTokenScripts { extraTokensJsonAgeFilePaths = [ devops-templates.lib.sharedTokensFile ]; ... }` merges it into `.tokens.sh` locally and in CI, so `tokenVariablePairs` can use its keys.

After changing `nix/lib/master-identity.nix`, run `agenix update-masterkeys`, push, and run `nix flake update devops-templates` followed by `tofuage update-masterkeys && tofuage rekey -a` in terraflake.
