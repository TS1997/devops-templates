---
name: laravel-package-development
description: "Use this skill for Laravel package development in repositories generated from the devops-templates laravel-package template. Trigger for package make commands, Testbench, Workbench paths, package models, migrations, factories, seeders, tests, Filament resources/pages/widgets/clusters, service providers, config, translations, and package scaffolding. Prefer the package wrapper over php artisan or vendor/bin/testbench for generating files."
license: MIT
metadata:
  author: devops-templates
---

# Laravel Package Development

## Core Rule

Use the `package` wrapper for package-aware generation and Testbench/Artisan-style commands.

Prefer:

- `package make:model Post --migration --factory`
- `package make:migration create_posts_table`
- `package make:factory PostFactory --model=Post`
- `package list`
- `package migrate`

Avoid unless debugging the wrapper:

- `vendor/bin/testbench make:*`
- `php artisan make:*`
- Manually creating generated files in `workbench/`

## Why

Laravel package generation normally targets Testbench's Workbench application. The `package` wrapper runs the matching Testbench command, moves generated files into package directories, rewrites namespaces, removes duplicate imports, and removes the temporary `workbench` directory.

## Workflow

1. Inspect available commands with `package list`.
2. Inspect command options with `package <command> --help`.
3. Generate files with `package make:*`.
4. Check generated paths and namespaces before editing.
5. Run the smallest relevant test set, then `composer test` when appropriate.
6. Run `composer format` before finishing PHP changes.

## Expected Package Paths

- Package source: `src/`
- Migrations: `database/migrations/`
- Factories: `database/factories/`
- Tests: `tests/`
- Config: `config/`
- Views: `resources/views/`
- Translations: `resources/lang/`

## Testing

- Use Pest for tests.
- Prefer package test commands from Composer: `composer test`.
- If generating a test, prefer the package-aware generator through `package make:test` if available.

## Filament

For Filament package scaffolding, use `package make:filament-*` commands when available. The wrapper includes special handling for package-safe Filament generation and Workbench cleanup.
