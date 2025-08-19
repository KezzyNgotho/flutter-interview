<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Cache\RateLimiting\Limit;

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

        // API rate limiter: 100 req/min per user or IP
        RateLimiter::for('api', function ($request) {
            $userId = optional($request->user())->id ?: $request->ip();
            return [Limit::perMinute(100)->by($userId)];
        });
    }
}
