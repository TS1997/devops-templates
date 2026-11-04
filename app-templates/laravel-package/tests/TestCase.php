<?php

namespace PackageVendor\Skeleton\Tests;

use Illuminate\Database\Eloquent\Factories\Factory;
use Orchestra\Testbench\TestCase as Orchestra;

class TestCase extends Orchestra {
    /** Registers the providers of every installed package. */
    protected $enablesPackageDiscoveries = true;

    protected function setUp(): void {
        parent::setUp();

        Factory::guessFactoryNamesUsing(
            fn(string $modelName) => 'PackageVendor\\Skeleton\\Database\\Factories\\' . class_basename($modelName) . 'Factory'
        );
    }

    // BEGIN FILAMENT_PLUGIN
    protected function getPackageProviders($app) {
        return [
            TestPanelProvider::class,
        ];
    }

    // END FILAMENT_PLUGIN
    public function getEnvironmentSetUp($app) {
        config()->set('database.default', 'testing');

        /*
         foreach (\Illuminate\Support\Facades\File::allFiles(__DIR__ . '/../database/migrations') as $migration) {
            (include $migration->getRealPath())->up();
         }
         */
    }
}
