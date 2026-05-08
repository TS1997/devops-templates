<?php

namespace PackageVendor\Skeleton;

use Spatie\LaravelPackageTools\Package;
use Spatie\LaravelPackageTools\PackageServiceProvider;

class SkeletonServiceProvider extends PackageServiceProvider {
    public function configurePackage(Package $package): void {
        /*
         * This class is a Package Service Provider
         *
         * More info: https://github.com/spatie/laravel-package-tools
         */
        $package
            ->name('{{package_slug}}')
            ->discoversMigrations()
            ->runsMigrations()
            ->hasConfigFile();
    }

    public function packageBooted(): void {
        $this->configureTranslations();
    }

    protected function configureTranslations(): void {
        // Load translations
        $this->loadTranslationsFrom(__DIR__ . '/../resources/lang', '{{package_slug}}');

        // Publish translations
        $this->publishes([
            __DIR__ . '/../resources/lang' => lang_path('vendor/{{package_slug}}'),
        ], '{{package_slug}}-translations');
    }
}
