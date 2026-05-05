<?php

namespace TS1997\{{class_name}}\Commands;

use Illuminate\Console\Command;

class {{class_name}}Command extends Command {
    public $signature = '{{package_slug}}';

    public $description = 'My command';

    public function handle(): int {
        $this->comment('All done');

        return self::SUCCESS;
    }
}
