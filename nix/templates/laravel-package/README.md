# {{package_description}}

This is where your description should go. Limit it to a paragraph or two. Consider adding a small example.

## Installation

You can install the package via composer:

```bash
composer require ts1997/{{package_slug}}
```

You can publish and run the migrations with:

```bash
php artisan vendor:publish --tag="{{package_slug}}-migrations"
php artisan migrate
```

You can publish the config file with:

```bash
php artisan vendor:publish --tag="{{package_slug}}-config"
```

Optionally, you can publish the views using

```bash
php artisan vendor:publish --tag="{{package_slug}}-views"
```

## Testing

```bash
composer test
```
