<?php

namespace TS1997\{{class_name}}\Tests;

use Illuminate\Database\Eloquent\Factories\Factory;
use Orchestra\Testbench\TestCase as Orchestra;
use TS1997\{{class_name}}\{{class_name}}ServiceProvider;

class TestCase extends Orchestra {
    protected function setUp(): void {
        parent::setUp();

        Factory::guessFactoryNamesUsing(
            fn(string $modelName) => 'TS1997\\{{class_name}}\\Database\\Factories\\' . class_basename($modelName) . 'Factory'
        );
    }

    protected function getPackageProviders($app) {
        return [
            {{class_name}}ServiceProvider::class,
        ];
    }

    public function getEnvironmentSetUp($app) {
        config()->set('database.default', 'testing');

        /*
         foreach (\Illuminate\Support\Facades\File::allFiles(__DIR__ . '/../database/migrations') as $migration) {
            (include $migration->getRealPath())->up();
         }
         */
    }
}
