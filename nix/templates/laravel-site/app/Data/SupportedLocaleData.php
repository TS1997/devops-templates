<?php

namespace App\Data;

use Spatie\LaravelData\Data;

class SupportedLocaleData extends Data {
    public function __construct(
        public string $name,
        public string $script,
        public string $native,
        public string $regional,
    ) {}
}
