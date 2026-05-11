---
name: laravel-package-dev-tools
description: "Use when working on Laravel packages that use ts1997 Laravel Package Dev Tools, package-oriented devenv templates, the package command wrapper, Testbench, Laravel Boost discovery, package Pint config, or Composer require-dev tooling."
---

# Laravel Package Dev Tools

## When to Use

Use this skill before changing Laravel packages that use `ts1997/laravel-package-dev-tools` or the `ts1997` devenv Laravel package template.

Common signals:

- `ts1997/laravel-package-dev-tools` in `require-dev`
- `services.ts1997.laravelPackage` in `devenv.nix`
- `package make:*`, `package list`, or other `package` wrapper commands
- `orchestra/testbench`, `spatie/laravel-package-tools`, or `pestphp/pest-plugin-laravel`
- Package-focused `composer.json` files with `extra.laravel.providers`
- Questions about package testing, package publishing, Pint, AI skills, or Testbench

## Mental Model

This repository is for package authoring, not consuming Laravel applications.

Keep development-only tooling in `require-dev`. Composer does not install a package's transitive `require-dev` dependencies when that package is installed by a Laravel application, so `ts1997/laravel-package-dev-tools` should not leak into sites that use the package.

## Pint Rules

Use the package-dev-tools Pint config for Laravel packages.

Publish it into the package root with:

```bash
vendor/bin/testbench vendor:publish --tag=package-dev-tools-pint --force
```

If a package already has a `pint.json`, review it before overwriting. Do not publish the package-dev Pint config into a consuming Laravel application.

## Testing Rules

Prefer package test commands defined by the package's `composer.json` or devenv template.

Common commands:

- `composer test`
- `vendor/bin/pest`
- `vendor/bin/testbench package:discover --ansi`

Use Testbench-aware commands when checking Laravel service providers, migrations, config publishing, commands, and package discovery.

## Package Command Rules

When `services.ts1997.laravelPackage.enable = true`, the devenv template exposes a `package` script that wraps `vendor/bin/testbench` from the package root.

Use `package make:*` instead of `vendor/bin/testbench make:*` when generating package files:

```bash
package make:model Post --migration --factory
package make:migration create_posts_table
package make:factory PostFactory --model=Post
```

The wrapper:

- Requires a package-root `composer.json` and `vendor/bin/testbench`; run `composer install` first if Testbench is missing.
- Reads the package PSR-4 namespace from `composer.json` (`src/`, plus optional `database/factories/` and `tests/` mappings).
- Runs the matching Testbench generator, detects newly generated files, and moves application/workbench outputs into package directories.
- Relocates `workbench/app/` and `app/` outputs to `src/`, including `Console/Commands/` to `src/Commands/`.
- Relocates generated `database/`, `tests/`, `routes/`, `config/`, and `resources/` files into the package root.
- Rewrites generated PHP namespaces and references from `App\`, `Workbench\App\`, and database factory/seeder namespaces to the package namespaces.
- Removes duplicate `use` imports, deletes the temporary `workbench` directory, and prunes empty `app` directories.
- Refuses to overwrite existing destination files unless `--force` or `-f` is passed.

For non-generator Testbench or Artisan-style commands, still prefer the wrapper so the same environment is used:

```bash
package list
```

For Filament generators, the wrapper temporarily registers a package panel when needed and adds `--panel=package` for supported `make:filament-*` commands if no panel is provided.

## Day-to-Day Guidance

- Treat the package repository as the root of code generation and formatting.
- Keep generated application-only files out of the package unless they are fixtures or Testbench workbench files.
- Put reusable package services under `src/` and tests under `tests/`.
- Keep package development dependencies in `require-dev`; only runtime package dependencies belong in `require`.
- Use Boost discovery after installing or updating this package so agents can find these instructions.

## Laravel Boost Rules

This package fixes `boost:*` command paths automatically when it is booted through Testbench, so Boost inspects the package root instead of `vendor/orchestra/testbench-core/laravel`.

Run Boost discovery through Testbench:

```bash
vendor/bin/testbench boost:update --discover
```

For Boost MCP support, publish the package-root `artisan` shim once:

```bash
vendor/bin/testbench vendor:publish --tag=package-dev-tools-artisan --force
```

The shim proxies MCP `php artisan ...` calls to `vendor/bin/testbench ...`. Keep it in each package repository that uses Boost MCP servers, because MCP clients call the root `artisan` file before Laravel can boot this package's service provider.

## Avoid

- Do not add `ts1997/laravel-package-dev-tools` to a package's runtime `require` section.
- Do not publish this package's Pint config into Laravel sites that merely consume the package.
- Do not assume a package has a full Laravel application root.
- Do not commit `vendor/`, `.devenv*`, `.direnv`, `devenv.local.nix`, generated secrets, coverage reports, or machine-specific overrides.