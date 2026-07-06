<?php

namespace App\Providers;

use Spatie\LaravelTypeScriptTransformer\LaravelData\Transformers\DataClassTransformer;
use Spatie\LaravelTypeScriptTransformer\LaravelTypeScriptTransformerExtension;
use Spatie\LaravelTypeScriptTransformer\TypeScriptTransformerApplicationServiceProvider as BaseTypeScriptTransformerServiceProvider;
use Spatie\TypeScriptTransformer\Formatters\PrettierFormatter;
use Spatie\TypeScriptTransformer\Transformers\AttributedClassTransformer;
use Spatie\TypeScriptTransformer\Transformers\EnumTransformer;
use Spatie\TypeScriptTransformer\TypeScriptTransformerConfigFactory;
use Spatie\TypeScriptTransformer\Writers\ModuleWriter;
use TS1997\TypeScriptTransformerExtras\Transformers\StripSuffixTransformer;

class TypeScriptTransformerServiceProvider extends BaseTypeScriptTransformerServiceProvider {
    protected function configure(TypeScriptTransformerConfigFactory $config): void {
        $config
            ->outputDirectory(resource_path('js/generated'))
            ->prependTransformer(new StripSuffixTransformer(new DataClassTransformer(nullableAsOptional: true)))
            ->transformer(AttributedClassTransformer::class)
            ->transformer(EnumTransformer::class)
            ->transformDirectories(app_path())
            ->extension(new LaravelTypeScriptTransformerExtension)
            ->writer(new ModuleWriter)
            ->formatter(PrettierFormatter::class);
    }
}
