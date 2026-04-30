<?php

use Illuminate\Support\Facades\Route;
use Inertia\Inertia;
use Laravel\Fortify\Features;
use Mcamara\LaravelLocalization\Facades\LaravelLocalization;
use Mcamara\LaravelLocalization\Middleware\LaravelLocalizationRedirectFilter;
use Mcamara\LaravelLocalization\Middleware\LocaleSessionRedirect;

Route::group([
    'prefix' => LaravelLocalization::setLocale(),
    'middleware' => [
        LocaleSessionRedirect::class,
        LaravelLocalizationRedirectFilter::class,
    ],
], function () {
    Route::get('/', fn () => Inertia::render('welcome', [
        'canRegister' => Features::enabled(Features::registration()),
    ]))->name('home');

    Route::middleware(['auth', 'verified'])->group(function () {
        Route::get('dashboard', fn () => Inertia::render('dashboard'))->name('dashboard');
    });

    require base_path('vendor/laravel/fortify/routes/routes.php');
    require __DIR__ . '/settings.php';
});
