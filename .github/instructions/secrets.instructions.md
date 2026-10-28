---
description: Shared (common) secrets in devops-templates and how projects, terraflake and CI consume them.
applyTo: "secrets/**,nix/lib/**,nix/pkgs/**,nix/utils/tokens.devenv.nix,.github/**,flake.nix,README.md"
---

# Shared secrets

## Layout
- `secrets/dev/tokens.json.age`: one age-encrypted JSON object with all common secrets, e.g. `composer_auth` (Composer `http-basic` for packages.bravomedia.se).
- `nix/lib/master-identity.nix`: the recipients, i.e. `people` (ssh pubkeys), `masterPubkey`, `ciPubkey` (same key as terraflake `secrets/ci-identity.pub`, private key = GitHub secret `CI_AGE_KEY`). `extraEncryptionPubkeys = people` there deliberately leaves CI out; CI is added only in `agenix-rekey.nix`.
- `nix/lib/agenix-rekey.nix`: `agenix-rekey.configure` with a plain-attrset node `devSecrets` (exported as flake output `agenix-rekey`; `nix flake check` warns "unknown flake output", harmless).
- `nix/lib/devshell.nix`: dev shell (`.envrc` = `use flake`) with `age`, the agenix-rekey CLI `agenix` and `select-age-identity`, which sets `AGE_IDENTITY` (an ssh key that is a recipient).
- `nix/lib/nixos.nix` (flake `lib`): exposes `mkTokenScripts`, `mkTofuScripts`, `masterIdentity`, `sharedTokensFile`.
- `nix/lib/mkTokenScripts.nixos.nix`: decrypts into a `@sh` export file (mode 600, atomic write, fingerprint-based `--is-fresh`). `extraTokensJsonAgeFilePaths` files are deep-merged first (`jq -s '.[0] * .[1]'`), so the main file wins on conflicts.
- `nix/utils/tokens.devenv.nix`: devenv option `services.ts1997.tokens.variables = [ "json_key:ENV_VAR" ]`. The output is `$DEVENV_STATE/tokens.sh`, sourced in `enterShell` via `lib.mkBefore`.

## Workflow (run in this repo's dev shell)
- `agenix edit secrets/dev/tokens.json.age`, `agenix view …`, then commit and push. Editing already encrypts to every recipient.
- After changing `people` or `ciPubkey`, run `agenix update-masterkeys`.
- Never run `agenix rekey` here. There are no hosts and CI is a direct recipient. The plain-attrset node lacks `storageMode`/`hostPubkey`, so `rekey` errors with `attribute 'storageMode' missing`. Rekey is only for NixOS hosts (terraflake).
- Check a change without printing values: `agenix view secrets/dev/tokens.json.age | grep -v '^Collecting\|^Age identity' | jq -c '[paths(scalars)|join(".")]'`. The dev shell hook prints `Age identity: …` on stdout, which breaks a plain `| jq`. Use `grep -ac '^-> ' file.age` to count recipients (currently 6: 4 people + master + CI).

## Consumers
- **Project (devenv)**: set `services.ts1997.tokens.variables = [ "composer_auth:COMPOSER_AUTH" ];`. Use top-level JSON keys only, because a dotted path would split `packages.bravomedia.se`.
  - `devenv.yaml` must point at `github:ts1997/devops-templates`, not a local path, before committing. Then `devenv update templates`.
  - If devops-templates is private, the project's `.envrc` needs the GitHub token block (`gh auth token` → `NIX_CONFIG extra-access-tokens`) before `use devenv`, as in terraflake. It can't live here, because the token is needed to fetch this repo.
- **terraflake**: `extraTokensJsonAgeFilePaths = [ devops-templates.lib.sharedTokensFile ]` (devshell.nix and secrets/ci.nix). Its `flake.lock` must point at a devops-templates rev that has this option (≥ b775eb9), so after pushing here run `nix flake update devops-templates` there.
- **CI**: `.github/actions/devenv-setup` takes input `age-key`. It writes `$RUNNER_TEMP/ci-age-key`, sets `AGE_IDENTITY`, and masks every line of the exported token values.
  - The workflows `laravel-deploy.yml` and `wordpress-deploy.yml` take optional secret `CI_AGE_KEY`. Callers pass `secrets: inherit`.
  - Composite actions can't read `secrets`, so the key must be passed in from the workflow.
  - `devenv-setup` uses `github.token` for Nix, which can't fetch a private devops-templates from another repo.
  - Projects whose own workflows don't use devenv (e.g. falkopingsmejeri-api `tests.yml`) don't get the secrets.

## Gotchas
- `nixpkgs` here is `cachix/devenv-nixpkgs/rolling`, which has no `lib.nixosSystem` or `nixos/`. That's why the agenix-rekey node is a plain attrset.
- Paths in `nix/lib/*` are relative to that folder (`../../secrets`, `../pkgs`).
- devenv git-hooks now installs via prek. A leftover `.git/hooks/pre-commit.legacy` from pre-commit makes hooks run twice with a "migration mode" warning, so delete it.
- Security: `CI_AGE_KEY` is shared with terraflake. Anyone who can edit a workflow in a repo with this secret can also decrypt terraflake's CI-rekeyed tofu tokens.
