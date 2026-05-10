#!/usr/bin/env php
<?php

declare(strict_types=1);

function fail(string $message, int $exitCode = 1): never {
    fwrite(STDERR, "Error: {$message}\n");
    exit($exitCode);
}

function usage(): never {
    fwrite(STDERR, <<<TXT
Usage:
    package make:<thing> [arguments] [options]

Examples:
    package make:model Post --migration --factory
    package make:migration create_posts_table
    package make:factory PostFactory --model=Post

TXT);

    exit(2);
}

function normalizePath(string $path): string {
    return str_replace('\\', '/', $path);
}

function trimNamespace(string $namespace): string {
    return trim($namespace, "\\ \t\n\r\0\x0B");
}

function composerPsr4Namespace(array $composer, string $directory): ?string {
    $directory = rtrim(normalizePath($directory), '/') . '/';
    $autoloads = [];

    foreach (['autoload', 'autoload-dev'] as $section) {
        if (isset($composer[$section]['psr-4']) && is_array($composer[$section]['psr-4'])) {
            $autoloads[] = $composer[$section]['psr-4'];
        }
    }

    foreach ($autoloads as $psr4) {
        foreach ($psr4 as $namespace => $paths) {
            foreach ((array) $paths as $path) {
                if (rtrim(normalizePath((string) $path), '/') . '/' === $directory) {
                    return trimNamespace((string) $namespace);
                }
            }
        }
    }

    return null;
}

function listFiles(array $roots): array {
    $files = [];

    foreach ($roots as $root) {
        if (!is_dir($root)) {
            continue;
        }

        $iterator = new RecursiveIteratorIterator(
            new RecursiveCallbackFilterIterator(
                new RecursiveDirectoryIterator($root, FilesystemIterator::SKIP_DOTS),
                static function (SplFileInfo $file): bool {
                    $name = $file->getFilename();

                    return !in_array($name, ['.git', '.devenv', 'node_modules', 'vendor'], true);
                }
            )
        );

        foreach ($iterator as $file) {
            if ($file->isFile()) {
                $files[normalizePath($file->getPathname())] = true;
            }
        }
    }

    ksort($files);

    return $files;
}

function runCommand(array $command): int {
    $escaped = array_map('escapeshellarg', $command);
    passthru(implode(' ', $escaped), $exitCode);

    return (int) $exitCode;
}

function removeEmptyDirectories(string $root): void {
    if (!is_dir($root)) {
        return;
    }

    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($root, FilesystemIterator::SKIP_DOTS),
        RecursiveIteratorIterator::CHILD_FIRST
    );

    foreach ($iterator as $path) {
        if ($path->isDir()) {
            @rmdir($path->getPathname());
        }
    }

    @rmdir($root);
}

function ensureDirectory(string $directory): void {
    if (!is_dir($directory) && !mkdir($directory, 0777, true) && !is_dir($directory)) {
        fail("Unable to create directory {$directory}.");
    }
}

function hasOption(array $args, string $option): bool {
    foreach ($args as $arg) {
        if ($arg === $option || str_starts_with($arg, $option . '=')) {
            return true;
        }
    }

    return false;
}

function commandNeedsPackageFilamentPanel(string $command): bool {
    return str_starts_with($command, 'make:filament-')
        && $command !== 'make:filament-panel';
}

function commandAcceptsPackageFilamentPanelOption(string $command): bool {
    return in_array($command, [
        'make:filament-cluster',
        'make:filament-page',
        'make:filament-relation-manager',
        'make:filament-resource',
        'make:filament-theme',
        'make:filament-user',
        'make:filament-widget',
    ], true);
}

function createTemporaryPackageFilamentPanel(): array {
    $providerPath = 'workbench/app/Providers/Filament/PackageMakePanelProvider.php';
    $providersPath = 'workbench/bootstrap/providers.php';
    $createdFiles = [];
    $originalProviders = is_file($providersPath) ? file_get_contents($providersPath) : null;
    $packageRoot = var_export(normalizePath(getcwd()), true);

    ensureDirectory(dirname($providerPath));
    ensureDirectory(dirname($providersPath));

    if (!is_file($providerPath)) {
        $provider = str_replace('{{PACKAGE_ROOT}}', $packageRoot, <<<'PHP'
<?php

namespace Workbench\App\Providers\Filament;

use Filament\Panel;
use Filament\PanelProvider;

class PackageMakePanelProvider extends PanelProvider {
    private const PACKAGE_ROOT = {{PACKAGE_ROOT}};

    public function panel(Panel $panel): Panel {
        return $panel
            ->default()
            ->id('package')
            ->path('package')
            ->discoverResources(in: self::PACKAGE_ROOT . '/workbench/app/Filament/Resources', for: 'Workbench\\App\\Filament\\Resources')
            ->discoverPages(in: self::PACKAGE_ROOT . '/workbench/app/Filament/Pages', for: 'Workbench\\App\\Filament\\Pages')
            ->discoverClusters(in: self::PACKAGE_ROOT . '/workbench/app/Filament/Clusters', for: 'Workbench\\App\\Filament\\Clusters');
    }
}
PHP);

        file_put_contents($providerPath, $provider);
        $createdFiles[] = $providerPath;
    }

    $providerClass = 'Workbench\\App\\Providers\\Filament\\PackageMakePanelProvider::class';
    $providers = is_string($originalProviders) ? $originalProviders : "<?php\n\nreturn [\n];\n";

    if (!str_contains($providers, $providerClass)) {
        $providers = preg_replace('/\];\s*$/', "    {$providerClass},\n];\n", $providers, 1) ?? $providers;
        file_put_contents($providersPath, $providers);

        if ($originalProviders === null) {
            $createdFiles[] = $providersPath;
        }
    }

    return [
        'createdFiles' => $createdFiles,
        'providersPath' => $providersPath,
        'originalProviders' => $originalProviders,
    ];
}

function cleanupTemporaryPackageFilamentPanel(?array $temporaryPanel): void {
    if ($temporaryPanel === null) {
        return;
    }

    if (is_string($temporaryPanel['originalProviders'])) {
        file_put_contents($temporaryPanel['providersPath'], $temporaryPanel['originalProviders']);
    }

    foreach (array_reverse($temporaryPanel['createdFiles']) as $file) {
        if (is_file($file)) {
            unlink($file);
        }
    }

    removeEmptyDirectories('workbench/app/Providers/Filament');
    removeEmptyDirectories('workbench/bootstrap');
}

function removeDirectory(string $root): void {
    if (!is_dir($root)) {
        return;
    }

    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($root, FilesystemIterator::SKIP_DOTS),
        RecursiveIteratorIterator::CHILD_FIRST
    );

    foreach ($iterator as $path) {
        if ($path->isDir() && !$path->isLink()) {
            rmdir($path->getPathname());

            continue;
        }

        unlink($path->getPathname());
    }

    rmdir($root);
}

function relativeNamespace(string $relativePath): string {
    $directory = dirname($relativePath);

    if ($directory === '.' || $directory === '') {
        return '';
    }

    return str_replace('/', '\\', $directory);
}

function namespaceForDestination(string $path, string $packageNamespace, ?string $factoryNamespace, ?string $testNamespace): ?string {
    $path = normalizePath($path);

    if (str_starts_with($path, 'src/')) {
        $suffix = relativeNamespace(substr($path, strlen('src/')));

        return $suffix === '' ? $packageNamespace : $packageNamespace . '\\' . $suffix;
    }

    if (str_starts_with($path, 'database/factories/')) {
        $base = $factoryNamespace ?: $packageNamespace . '\\Database\\Factories';
        $suffix = relativeNamespace(substr($path, strlen('database/factories/')));

        return $suffix === '' ? $base : $base . '\\' . $suffix;
    }

    if (str_starts_with($path, 'database/seeders/')) {
        $base = $packageNamespace . '\\Database\\Seeders';
        $suffix = relativeNamespace(substr($path, strlen('database/seeders/')));

        return $suffix === '' ? $base : $base . '\\' . $suffix;
    }

    if (str_starts_with($path, 'tests/') && $testNamespace !== null) {
        $suffix = relativeNamespace(substr($path, strlen('tests/')));

        return $suffix === '' ? $testNamespace : $testNamespace . '\\' . $suffix;
    }

    return null;
}

function deduplicateUseStatements(string $contents): string {
    $seen = [];

    return preg_replace_callback(
        '/^[ \t]*use\s+([^;]+);[ \t]*(?:\R|$)/m',
        static function (array $matches) use (&$seen): string {
            $use = strtolower(preg_replace('/\s+/', ' ', ltrim(trim($matches[1]), '\\')) ?? trim($matches[1]));

            if (isset($seen[$use])) {
                return '';
            }

            $seen[$use] = true;

            return $matches[0];
        },
        $contents
    ) ?? $contents;
}

function patchPhpFile(string $path, string $packageNamespace, ?string $factoryNamespace, ?string $testNamespace): bool {
    if (!str_ends_with($path, '.php') || !is_file($path)) {
        return false;
    }

    $contents = file_get_contents($path);

    if ($contents === false) {
        fail("Unable to read generated file: {$path}");
    }

    $original = $contents;
    $namespace = namespaceForDestination($path, $packageNamespace, $factoryNamespace, $testNamespace);

    if ($namespace !== null && !str_contains($path, 'database/migrations/')) {
        if (preg_match('/^namespace\s+[^;]+;/m', $contents) === 1) {
            $contents = preg_replace('/^namespace\s+[^;]+;/m', 'namespace ' . $namespace . ';', $contents, 1) ?? $contents;
        } else {
            $contents = preg_replace('/<\?php\s*/', "<?php\n\nnamespace {$namespace};\n\n", $contents, 1) ?? $contents;
        }
    }

    $factoryNs = $factoryNamespace ?: $packageNamespace . '\\Database\\Factories';
    $replacements = [
        'Workbench\\App\\' => $packageNamespace . '\\',
        'App\\' => $packageNamespace . '\\',
        'Workbench\\Database\\Factories\\' => $factoryNs . '\\',
        'Database\\Factories\\' => $factoryNs . '\\',
        'Workbench\\Database\\Seeders\\' => $packageNamespace . '\\Database\\Seeders\\',
        'Database\\Seeders\\' => $packageNamespace . '\\Database\\Seeders\\',
        'namespace Workbench\\Database\\Factories;' => 'namespace ' . $factoryNs . ';',
        'namespace Database\\Factories;' => 'namespace ' . $factoryNs . ';',
        'namespace Workbench\\Database\\Seeders;' => 'namespace ' . $packageNamespace . '\\Database\\Seeders;',
        'namespace Database\\Seeders;' => 'namespace ' . $packageNamespace . '\\Database\\Seeders;',
    ];

    $contents = str_replace(array_keys($replacements), array_values($replacements), $contents);
    $contents = deduplicateUseStatements($contents);

    if ($contents !== $original) {
        file_put_contents($path, $contents);

        return true;
    }

    return false;
}

function destinationForGeneratedFile(string $path): ?string {
    $path = normalizePath($path);
    $testbenchLaravelPrefix = 'vendor/orchestra/testbench-core/laravel/';

    if (str_starts_with($path, $testbenchLaravelPrefix)) {
        $path = substr($path, strlen($testbenchLaravelPrefix));
    }

    $prefixes = [
        'workbench/app/' => 'src/',
        'app/' => 'src/',
        'workbench/database/' => 'database/',
        'database/' => 'database/',
        'workbench/tests/' => 'tests/',
        'tests/' => 'tests/',
        'workbench/routes/' => 'routes/',
        'routes/' => 'routes/',
        'workbench/config/' => 'config/',
        'config/' => 'config/',
        'workbench/resources/' => 'resources/',
        'resources/' => 'resources/',
    ];

    foreach ($prefixes as $sourcePrefix => $destinationPrefix) {
        if (!str_starts_with($path, $sourcePrefix)) {
            continue;
        }

        $relative = substr($path, strlen($sourcePrefix));

        if ($sourcePrefix === 'workbench/app/' || $sourcePrefix === 'app/') {
            $relative = preg_replace('#^Console/Commands/#', 'Commands/', $relative) ?? $relative;
        }

        return $destinationPrefix . $relative;
    }

    return null;
}

$args = $_SERVER['argv'];
array_shift($args);

if ($args === [] || in_array($args[0], ['-h', '--help'], true)) {
    usage();
}

$command = array_shift($args);
$shouldRelocateGeneratedFiles = str_starts_with($command, 'make:');

if (!is_file('composer.json')) {
    fail('Run this command from the Laravel package root; composer.json was not found.');
}

if (!is_file('vendor/bin/testbench')) {
    fail('vendor/bin/testbench was not found. Run composer install first.');
}

$composer = json_decode((string) file_get_contents('composer.json'), true);

if (!is_array($composer)) {
    fail('Unable to parse composer.json.');
}

$packageNamespace = composerPsr4Namespace($composer, 'src/')
    ?? fail('Unable to find a PSR-4 namespace mapped to src/ in composer.json.');
$factoryNamespace = composerPsr4Namespace($composer, 'database/factories/');
$testNamespace = composerPsr4Namespace($composer, 'tests/');
$force = in_array('--force', $args, true) || in_array('-f', $args, true);
$temporaryPanel = null;

if (commandNeedsPackageFilamentPanel($command)) {
    $temporaryPanel = createTemporaryPackageFilamentPanel();
    register_shutdown_function(static function () use (&$temporaryPanel): void {
        cleanupTemporaryPackageFilamentPanel($temporaryPanel);
    });

    if (commandAcceptsPackageFilamentPanelOption($command) && !hasOption($args, '--panel')) {
        $args[] = '--panel=package';
    }
}

if (!$shouldRelocateGeneratedFiles) {
    $exitCode = runCommand(array_merge(['vendor/bin/testbench', $command], $args));
    cleanupTemporaryPackageFilamentPanel($temporaryPanel);

    exit($exitCode);
}

$trackedRoots = [
    'workbench',
    'app',
    'database',
    'tests',
    'src',
    'routes',
    'config',
    'resources',
    'vendor/orchestra/testbench-core/laravel',
];
$before = listFiles($trackedRoots);
$exitCode = runCommand(array_merge(['vendor/bin/testbench', $command], $args));

if ($exitCode !== 0) {
    cleanupTemporaryPackageFilamentPanel($temporaryPanel);

    exit($exitCode);
}

$after = listFiles($trackedRoots);
$newFiles = array_values(array_diff(array_keys($after), array_keys($before)));
$moved = [];
$patched = [];
$kept = [];

foreach ($newFiles as $file) {
    $destination = destinationForGeneratedFile($file);

    if ($destination === null || $destination === $file) {
        $kept[] = $file;
        continue;
    }

    if (file_exists($destination)) {
        if (!$force) {
            fail("Refusing to overwrite {$destination}. Re-run with --force if that is intended.");
        }

        if (is_dir($destination)) {
            fail("Cannot overwrite directory {$destination}.");
        }

        unlink($destination);
    }

    $destinationDirectory = dirname($destination);

    if (!is_dir($destinationDirectory) && !mkdir($destinationDirectory, 0777, true) && !is_dir($destinationDirectory)) {
        fail("Unable to create directory {$destinationDirectory}.");
    }

    if (!rename($file, $destination)) {
        fail("Unable to move {$file} to {$destination}.");
    }

    $moved[$file] = $destination;
}

removeDirectory('workbench');
removeEmptyDirectories('app');

$filesToPatch = array_values(array_unique(array_merge(array_values($moved), $kept)));

foreach ($filesToPatch as $file) {
    if (patchPhpFile($file, $packageNamespace, $factoryNamespace, $testNamespace)) {
        $patched[] = $file;
    }
}

if ($moved === [] && $kept === []) {
    echo "No new generated files were detected.\n";
    exit(0);
}

foreach ($moved as $source => $destination) {
    echo "Moved {$source} -> {$destination}\n";
}

foreach ($kept as $file) {
    echo "Created {$file}\n";
}

foreach ($patched as $file) {
    echo "Patched {$file}\n";
}
