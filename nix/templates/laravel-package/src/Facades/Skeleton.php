<?php

namespace TS1997\Skeleton\Facades;

use Illuminate\Support\Facades\Facade;

/**
 * @see \TS1997\Skeleton\Skeleton
 */
class Skeleton extends Facade {
    protected static function getFacadeAccessor(): string {
        return \TS1997\Skeleton\Skeleton::class;
    }
}
