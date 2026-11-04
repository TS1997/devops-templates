<?php

namespace App\Data\Pages\Settings;

use Spatie\LaravelData\Data;

class ProfilePageData extends Data {
    public function __construct(
        public bool $mustVerifyEmail,
        public ?string $status
    ) {}
}
