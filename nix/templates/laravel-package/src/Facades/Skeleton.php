<?php

namespace PackageVendor\Skeleton\Facades;

use Illuminate\Support\Facades\Facade;

/**
 * @see \PackageVendor\Skeleton\Skeleton
 */
class Skeleton extends Facade {
    protected static function getFacadeAccessor(): string {
        return \PackageVendor\Skeleton\Skeleton::class;
    }
}
