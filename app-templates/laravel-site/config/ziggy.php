<?php

return [
    /*
     * Routes matching these patterns are excluded from the generated Ziggy
     * route list that is shared with the frontend.
     */
    'except' => [
        'boost.*',
        'storage.*',
        'filament.*',
        'livewire.*',
        'default-livewire.*',
    ],
];
