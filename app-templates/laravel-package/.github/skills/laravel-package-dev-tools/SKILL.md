---
name: laravel-package-dev-tools
description: "Use when working on Laravel packages that use ts1997 Laravel Package Dev Tools, package-oriented devenv templates, the package command wrapper, Testbench, Laravel Boost discovery, or Composer require-dev tooling."
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
- Questions about package testing, package publishing, AI skills, or Testbench

## Mental Model

This repository is for Laravel package authoring, not consuming Laravel applications.

Development tooling must remain isolated from consuming applications.

Keep development-only tooling in `require-dev`. Composer does not install a package's transitive `require-dev` dependencies when that package is installed by a Laravel application, so `ts1997/laravel-package-dev-tools` should never leak into sites that consume the package.

## Environment Assumptions

This repository may NOT contain:

- a full Laravel application
- a root `artisan` file
- installed Composer dependencies
- published config files
- booted service providers
- writable application paths outside the package root

Before running framework-aware commands:

1. Ensure `composer install` has been run.
2. Prefer `package ...` wrapper commands.
3. Use Testbench-aware execution paths.

## Repository Root

Run commands from the package repository root unless explicitly required otherwise.

Do not change working directories into temporary Testbench workbench paths unless debugging Testbench itself.

## Command Priority

When multiple equivalent commands exist, use them in this order:

1. `package ...` wrapper commands
2. Composer scripts defined by the repository
3. `vendor/bin/testbench ...`
4. direct `artisan` commands
5. direct vendor binaries

Do not bypass the wrapper unless debugging the wrapper itself.

## Testing Rules

Prefer package test commands defined by the package's `composer.json` or devenv template.

Common commands:

```bash
composer test
vendor/bin/pest
vendor/bin/testbench package:discover --ansi
```

Use Testbench-aware commands when checking:

- Laravel service providers
- package discovery
- migrations
- config publishing
- commands
- route registration
- views
- translations
- assets

## Package Command Rules

When `services.ts1997.laravelPackage.enable = true`, the devenv template exposes a `package` script that wraps `vendor/bin/testbench` from the package root.

Use `package make:*` instead of `vendor/bin/testbench make:*` when generating package files:

```bash
package make:model Post --migration --factory
package make:migration create_posts_table
package make:factory PostFactory --model=Post
```

For non-generator Testbench or Artisan-style commands, still prefer the wrapper so the same environment is used:

```bash
package list
package migrate
package test
```

The wrapper automatically:

- runs commands from the package root
- uses Testbench-aware execution
- relocates generated package files into package directories
- rewrites generated namespaces to package namespaces
- cleans temporary workbench artifacts
- prevents accidental overwrites unless `--force` or `-f` is passed

For Filament generators, the wrapper temporarily registers a package panel when needed and adds `--panel=package` for supported `make:filament-*` commands if no panel is provided.

## File Placement Rules

Unless explicitly required for Testbench fixtures or workbench scenarios:

- application code belongs in `src/`
- tests belong in `tests/`
- config belongs in `config/`
- routes belong in `routes/`
- translations belong in `resources/lang/`
- views belong in `resources/views/`
- assets belong in `resources/`
- migrations belong in `database/migrations/`
- factories belong in `database/factories/`
- seeders belong in `database/seeders/`

Do not create or keep generated Laravel application files under:

- `app/`
- `bootstrap/`
- `storage/`
- `public/`

unless the repository explicitly uses a workbench application.

## Dependency Rules

Runtime dependencies required by consuming applications belong in `require`.

Development-only tooling belongs in `require-dev`.

Never move package development tooling from `require-dev` into `require` unless explicitly instructed.

Before adding a dependency:

1. Determine whether it is runtime or development-only.
2. Prefer existing repository dependencies when possible.
3. Avoid duplicating Laravel framework components already provided through Testbench or Illuminate packages.
4. Avoid adding unnecessary Laravel application dependencies to reusable packages.

## Testbench Context

This package is executed through Orchestra Testbench, not a standalone Laravel application.

Important implications:

- Laravel paths may resolve differently than in normal applications.
- Service providers are booted through Testbench.
- Workbench directories may be temporary generation artifacts.
- Package discovery and publishing should be validated through Testbench commands.
- Generated application paths may need relocation into package directories.

## Formatting and Static Analysis

Prefer repository-defined Composer scripts for formatting and analysis.

Examples may include:

```bash
composer format
composer lint
composer analyse
composer test
```

Do not assume Pint, PHPStan, Rector, Pest, or PHPUnit are installed globally.

Prefer local project binaries and Composer scripts over global tooling.

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

The shim proxies MCP `php artisan ...` calls to `vendor/bin/testbench ...`.

Keep the shim in each package repository that uses Boost MCP servers, because MCP clients call the root `artisan` file before Laravel can boot this package's service provider.

## Day-to-Day Guidance

- Treat the package repository as the root of generation, formatting, analysis, and testing.
- Keep reusable package services under `src/`.
- Keep tests under `tests/`.
- Keep consuming application concerns out of the package unless explicitly required.
- Prefer package-oriented abstractions over application-specific implementations.
- Use Boost discovery after installing or updating this package so agents can find these instructions.
- Prefer deterministic commands and repository-defined scripts over ad-hoc shell commands.

## Safety Rules

Do not automatically run:

- `composer update`
- broad dependency upgrades
- database-destructive commands
- cache-clearing commands
- publishing commands with `--force`
- Pint, Rector, or PHP-CS-Fixer across the entire repository
- large automated refactors
- destructive filesystem cleanup outside known generated paths

unless explicitly requested.

## Common Mistakes to Avoid

- Do not assume this repository is a Laravel application.
- Do not assume a normal `artisan` workflow exists.
- Do not use `php artisan` directly unless the repository provides an artisan shim.
- Do not generate files into `app/` unless explicitly required.
- Do not install development tooling as runtime dependencies.
- Do not bypass the `package` wrapper for generators.
- Do not assume workbench-generated paths are permanent source locations.
- Do not commit temporary Testbench or devenv artifacts.
- Do not rely on globally installed PHP tooling.
- Do not assume package consumers use the same Laravel version as the package test environment.

## Avoid

Do not commit:

- `vendor/`
- `.devenv*`
- `.direnv`
- `devenv.local.nix`
- generated secrets
- coverage reports
- machine-specific overrides
- temporary workbench artifacts
- IDE-generated local state files

Do not:

- add `ts1997/laravel-package-dev-tools` to runtime `require`
- publish this package's Pint config into consuming Laravel applications
- assume a package repository contains a full Laravel application
- commit generated application-only files unless intentionally used as fixtures or workbench files
