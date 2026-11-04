<?php

namespace PackageVendor\Skeleton\Tests;

use Filament\Panel;
use Filament\PanelProvider;
use PackageVendor\Skeleton\Filament\SkeletonPlugin;

class TestPanelProvider extends PanelProvider {
    public function panel(Panel $panel): Panel {
        return $panel
            ->default()
            ->id('admin')
            ->path('admin')
            ->plugin(SkeletonPlugin::make());
    }
}
