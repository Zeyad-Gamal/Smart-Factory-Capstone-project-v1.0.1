<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Support\Facades\RateLimiter;

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
        
    RateLimiter::for('machines-control', function ($request) {
    return Limit::perMinute(5);
});

RateLimiter::for('machines-read', function ($request) {
    return Limit::perMinute(120);
});

RateLimiter::for('scada-read', function ($request) {
    return Limit::perMinute(120);
});

RateLimiter::for('scada-write', function ($request) {
    return Limit::perMinute(20);
});

RateLimiter::for('soc-stream', function ($request) {
    return Limit::perMinute(200);
});

RateLimiter::for('logs-read', function ($request) {
    return Limit::perMinute(60);
});

    }
}
