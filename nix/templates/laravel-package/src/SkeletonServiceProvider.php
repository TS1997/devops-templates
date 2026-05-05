<?php

namespace TS1997\{{class_name}};

use Spatie\LaravelPackageTools\Package;
use Spatie\LaravelPackageTools\PackageServiceProvider;
use TS1997\{{class_name}}\Commands\{{class_name}}Command;

class {{class_name}}ServiceProvider extends PackageServiceProvider {
    public function configurePackage(Package $package): void {
        /*
         * This class is a Package Service Provider
         *
         * More info: https://github.com/spatie/laravel-package-tools
         */
        $package
            ->name('{{package_slug}}')
            ->hasConfigFile()
            ->hasViews()
            ->hasMigration('create_{{migration_table_name}}_table')
            ->hasCommand({{class_name}}Command::class);
    }
}
