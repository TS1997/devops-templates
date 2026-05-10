<?php

namespace App\Data;

use Spatie\LaravelData\Data;

class SharedPagePropsData extends Data {
    public function __construct(
        public string $name,
        public ?UserData $user,
        public bool $sidebarOpen,
        public string $locale,
        public string $defaultLocale,
        /** @var array<string, SupportedLocaleData> */
        public array $supportedLocales,
    ) {}
}
