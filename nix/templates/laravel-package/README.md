# {{package_description}}

This is where your description should go. Limit it to a paragraph or two. Consider adding a small example.

## Installation

You can install the package via composer:

```bash
composer require ts1997/{{package_slug}}
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
use TS1997\Skeleton\Filament\SkeletonPlugin;

$panel
    ->plugins([
        SkeletonPlugin::make(),
    ]);
```

<!-- END FILAMENT_PLUGIN -->

## Testing

```bash
composer test
```
