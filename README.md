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

A project exports values from it when entering the devenv shell (decrypted with your `~/.ssh` key, or `$AGE_IDENTITY`, on every shell entry; nothing is written to disk, so run `direnv reload` after the encrypted file changes):

```nix
services.ts1997.tokens.variables = [ "composer_auth:COMPOSER_AUTH" ];
```

App options set these by default:

| Option                 | Exports                               | Default                                        |
| ---------------------- | ------------------------------------- | ---------------------------------------------- |
| `composer.auth.enable` | `composer_auth` → `COMPOSER_AUTH`     | on for Laravel site/package and WordPress      |
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
- terraflake: `mkTokenScripts { extraTokensJsonAgeFilePaths = [ devops-templates.lib.sharedTokensFile ]; ... }` merges it with terraflake's own bundle, so `tokenVariablePairs` can use its keys. Its `tokens` script prints `export` lines (the dev shell runs `eval "$(tokens)"`), or with `--github-env` masks the values and appends them to `$GITHUB_ENV` (CI).

After changing `nix/lib/master-identity.nix`, run `agenix update-masterkeys`, push, and run `nix flake update devops-templates` followed by `agenix update-masterkeys && agenix rekey -a` in terraflake.

### OpenTofu outputs in a deploy repo

Nix never reads the OpenTofu state. The deploy repo's root module exposes everything Nix needs in one non-sensitive output (`nix`), and a committed, generated `infrastructure.nix` holds a copy of it:

```nix
infraScripts = devops-templates.lib.mkInfraScripts { inherit pkgs lib; } {
  # Defaults:
  # tofuDir = "opentofu";
  # output = "nix";
  # file = "infrastructure.nix";
};
# -> packages: infra-sync, infra-check, ssh-host
```

Both run `tofu` in `tofuDir`, which must be initialized (`cd opentofu && tofu init`). The backend and provider credentials come from the environment (the dev shell or CI exports them, see `mkTokenScripts`). Run OpenTofu itself directly in `tofuDir`.

- `infra-sync`: runs `tofu plan` on the working tree and writes the output **as it will be after the apply** to `file`. Commit it together with the OpenTofu change; nobody has to apply first. If part of the output is only known after apply (in practice a new or replaced server's IP), it leaves the file alone and lists those values. Then push the OpenTofu change alone, let CI apply it, and run `infra-sync` again.
- `infra-check --plan FILE`: fails with a diff when the committed file differs from the output in a saved plan. Run it in CI's plan job, so a forgotten `infra-sync` stops the run before the apply. Only warns when the plan has values that are known after apply.
- `infra-check`: fails with a diff when the committed file differs from the applied output. Run it in CI after the apply, before deploying.
- `ssh-host --host=HOST [--user=USER] [-- SSH-ARGS...]`: `ssh USER@IP` (default `root`) with `nodes.HOST.ip` from the committed file, e.g. `ssh-host --host=bravomedia -- systemctl status`.

All of them refuse a missing or sensitive output. Plan files contain the variables (secrets), so they only live in a temp dir that is removed on exit.

CI flow (terraflake's `apply-infra-and-deploy.yml`):

```bash
plan -> infra-check --plan -> (approval) apply -> infra-check -> deploy
```

So any change, including changed node data of existing servers, goes in one commit and one CI run. Only a new server takes two rounds: its OpenTofu change first, then `infra-sync` and its NixOS host once CI has applied it.
