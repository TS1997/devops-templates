<?php

namespace TS1997\{{class_name}}\Facades;

use Illuminate\Support\Facades\Facade;

/**
 * @see \TS1997\{{class_name}}\{{class_name}}
 */
class {{class_name}} extends Facade {
    protected static function getFacadeAccessor(): string {
        return \TS1997\{{class_name}}\{{class_name}}::class;
    }
}
