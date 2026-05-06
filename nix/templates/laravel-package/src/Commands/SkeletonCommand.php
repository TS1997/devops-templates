<?php

namespace TS1997\Skeleton\Commands;

use Illuminate\Console\Command;

class SkeletonCommand extends Command {
    public $signature = '{{package_slug}}';

    public $description = 'My command';

    public function handle(): int {
        $this->comment('All done');

        return self::SUCCESS;
    }
}
