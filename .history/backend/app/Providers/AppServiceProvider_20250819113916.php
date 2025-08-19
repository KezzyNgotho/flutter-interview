<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Config;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        JsonResource::withoutWrapping();
        // Allow all origins for rapid testing (not for production)
        Config::set('cors.paths', ['api/*']);
        Config::set('cors.allowed_methods', ['*']);
        Config::set('cors.allowed_origins', ['*']);
        Config::set('cors.allowed_headers', ['*']);
        Config::set('cors.supports_credentials', false);
    }
}
