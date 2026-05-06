<?php

namespace TS1997\Skeleton\Filament;

use Filament\Contracts\Plugin;
use Filament\Panel;

class SkeletonPlugin implements Plugin {
    public function getId(): string {
        return '{{package_slug}}';
    }

    public function register(Panel $panel): void {
        // Register resources, pages, widgets, or render hooks here.
    }

    public function boot(Panel $panel): void {
        // Boot plugin services here.
    }

    public static function make(): static {
        return new static();
    }
}
