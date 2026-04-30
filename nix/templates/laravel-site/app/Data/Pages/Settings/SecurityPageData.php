<?php

namespace App\Data\Pages\Settings;

use Spatie\LaravelData\Data;
use Spatie\LaravelData\Optional;

class SecurityPageData extends Data {
    public function __construct(
        public bool $canManageTwoFactor,
        public bool|Optional $twoFactorEnabled = new Optional,
        public bool|Optional $requiresConfirmation = new Optional,
    ) {}
}
