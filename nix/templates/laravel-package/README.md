# {{package_description}}

This is where your description should go. Limit it to a paragraph or two. Consider adding a small example.

## Installation

You can install the package via composer:

```bash
composer require {{vendor_slug}}/{{package_slug}}
```

Most packages work without publishing anything. Only publish files when you need to customize them in your application.

If you need to customize the database migrations, publish them with:

```bash
php artisan vendor:publish --tag="{{package_slug}}-migrations"
```

Then run the migrations:

```bash
php artisan migrate
```

If you need to change the package configuration, publish the config file:

```bash
php artisan vendor:publish --tag="{{package_slug}}-config"
```

If you need to customize the package translations, publish them with:

```bash
php artisan vendor:publish --tag="{{package_slug}}-translations"
```

<!-- BEGIN FILAMENT_PLUGIN -->

## Filament plugin

Register the plugin in your Filament panel provider:

```php
use {{vendor_namespace}}\Skeleton\Filament\SkeletonPlugin;

$panel
    ->plugins([
        SkeletonPlugin::make(),
    ]);
```

<!-- END FILAMENT_PLUGIN -->

## Package development

This package includes Devenv tooling for running Testbench commands against the package while keeping generated files in package directories.

Use `package make:*` instead of `vendor/bin/testbench make:*` when generating package files:

```bash
package make:model Post --migration --factory
package make:migration create_posts_table
package make:factory PostFactory --model=Post
```

The command runs the matching Testbench generator, moves generated files out of Workbench paths, rewrites namespaces, removes duplicate imports, and deletes the temporary `workbench` directory.

For other Testbench or Artisan-style commands, use the same `package` wrapper:

```bash
package list
```

## Testing

```bash
package test
```
