---
description: "Use when working in Laravel package repositories generated from the devops-templates laravel-package template. Covers package make commands, Testbench generation, Workbench relocation, migrations, factories, tests, and Filament scaffolding."
applyTo: "**/*.php, **/*.blade.php, **/composer.json, **/README.md"
---

# Laravel Package Tooling

- This repository is a Laravel package, not a full Laravel application.
- Use the `package` wrapper for Testbench and Artisan-style commands.
- Use `package make:*` instead of `vendor/bin/testbench make:*` when generating package files.
- Do not use `php artisan make:*` for package scaffolding unless the command is unavailable through `package`.
- Do not manually create or keep generated files under `workbench/`.
- The `package` wrapper runs Testbench, relocates generated Workbench files into package directories, rewrites namespaces, removes duplicate imports, and removes the temporary `workbench` directory.

Common commands:

- `package list`
- `package make:model Post --migration --factory`
- `package make:migration create_posts_table`
- `package make:factory PostFactory --model=Post`
- `composer test`
- `composer format`
