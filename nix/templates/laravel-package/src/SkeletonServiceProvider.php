<?php

namespace PackageVendor\Skeleton;

// BEGIN FILAMENT_ASSETS
use Filament\Support\Facades\FilamentView;
use Filament\View\PanelsRenderHook;
use Illuminate\Support\HtmlString;
// END FILAMENT_ASSETS
use Override;
use Spatie\LaravelPackageTools\Package;
use Spatie\LaravelPackageTools\PackageServiceProvider;
// BEGIN TYPESCRIPT_TYPES
use TS1997\PackageTypes\Facades\PackageTypes;
// END TYPESCRIPT_TYPES

class SkeletonServiceProvider extends PackageServiceProvider {
    public function configurePackage(Package $package): void {
        /*
         * This class is a Package Service Provider
         *
         * More info: https://github.com/spatie/laravel-package-tools
         */
        $package
            ->name('{{package_slug}}')
            ->discoversMigrations()
            ->runsMigrations()
            ->hasConfigFile();
    }

    // BEGIN TYPESCRIPT_TYPES
    #[Override]
    public function packageRegistered(): void {
        $this->configureTypes();
    }

    // END TYPESCRIPT_TYPES
    #[Override]
    public function packageBooted(): void {
        // BEGIN FILAMENT_ASSETS
        $this->configureFilamentStyles();
        // END FILAMENT_ASSETS
        $this->configureTranslations();
    }

    // BEGIN TYPESCRIPT_TYPES
    protected function configureTypes(): void {
        PackageTypes::register(
            root: dirname(__DIR__),
        );
    }

    // END TYPESCRIPT_TYPES
    protected function configureTranslations(): void {
        // Load translations
        $this->loadTranslationsFrom(__DIR__ . '/../resources/lang', '{{package_slug}}');

        // Publish translations
        $this->publishes([
            __DIR__ . '/../resources/lang' => lang_path('vendor/{{package_slug}}'),
        ], '{{package_slug}}-translations');
    }

    // BEGIN FILAMENT_ASSETS
    protected function configureFilamentStyles(): void {
        FilamentView::registerRenderHook(
            PanelsRenderHook::STYLES_AFTER,
            fn(): HtmlString => new HtmlString($this->filamentStylesHtml()),
        );
    }

    protected function filamentStylesHtml(): string {
        $cssPath = __DIR__ . '/../resources/assets/dist/{{package_slug}}.css';

        return is_file($cssPath) ? sprintf(
            '<style data-{{package_slug}}>%s</style>',
            file_get_contents($cssPath),
        ) : '';
    }
    // END FILAMENT_ASSETS
}
