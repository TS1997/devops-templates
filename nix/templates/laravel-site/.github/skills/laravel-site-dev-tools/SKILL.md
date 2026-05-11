---
name: laravel-site-dev-tools
description: "Use when working on Laravel sites that use ts1997 Laravel Dev Tools, devenv.nix, devenv.yaml, services.ts1997.laravelSite, Laravel Boost discovery, Nix-managed env vars, or php artisan test with the devenv test wrapper."
---

# Laravel Site Dev Tools

## When to Use

Use this skill before changing Laravel sites that use `ts1997/laravel-dev-tools` and the `ts1997` devenv Laravel site template.

Common signals:

- `devenv.nix`, `devenv.yaml`, `.envrc`, `devenv.local.nix`
- `services.ts1997.laravelSite`
- `boost.json` or Laravel Boost generated files
- `ts1997/laravel-dev-tools` in `composer.json`
- Questions about environment variables, local services, testing, Pint, or Boost discovery

## Mental Model

The Laravel site template uses Nix/devenv as the local platform. Devenv manages local services and generates Laravel environment variables.

Do not manually duplicate generated values into `.env` unless the user explicitly asks for a non-devenv workflow. Prefer changing the relevant `services.ts1997.laravelSite` option in `devenv.nix`.

Prefer devenv-managed services over Docker Compose, Sail, Homebrew services, `php artisan serve`, or one-off database/cache/mail processes.

## Environment Rules

Treat devenv as the source of truth for:

- `APP_NAME`, `APP_ENV`, `APP_DEBUG`, `APP_URL`, locale, and timezone values
- database connection, host, port, socket, database, username, and password
- cache, session, queue, Redis, and Mailpit settings
- Vite and Inertia SSR environment values

If an app needs a new env value or service setting, add it to `services.ts1997.laravelSite` or its `env` option instead of editing generated runtime state.

## Testing Rules

Run Laravel tests with `php artisan test`.

This matters because `ts1997/laravel-dev-tools` replaces Laravel's test command. Outside `APP_ENV=testing`, the command delegates to the devenv `run-tests` wrapper, which prepares the correct test environment and then re-enters Laravel's normal test runner.

Examples:

- Use `php artisan test` for the full suite.
- Use `php artisan test --filter=SomeTest` for targeted runs.
- Do not bypass the wrapper with `vendor/bin/pest`, `vendor/bin/phpunit`, or direct `run-tests` unless the user specifically asks.

## Day-to-Day Guidance

- Use `devenv up` for the local service stack.
- Use `devenv shell` when commands need the Nix-managed toolchain.
- Use Laravel Boost tools and discovered instructions when available.
- Use the published package Pint config for PHP formatting.
- Keep changes in the template/devenv layer when they affect local infrastructure.

## Avoid

- Do not commit `.devenv*`, `.direnv`, `devenv.local.nix`, generated secrets, or machine-specific overrides.
- Do not hard-code local service ports or credentials in Laravel config.
- Do not start duplicate local database, Redis, Mailpit, queue, scheduler, Vite, Nginx, or PHP-FPM processes when devenv already manages them.