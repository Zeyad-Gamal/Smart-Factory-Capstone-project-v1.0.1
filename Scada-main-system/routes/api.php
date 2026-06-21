<?php

use App\Http\Controllers\Api\MachineController;
use App\Http\Controllers\Api\LogController;
use App\Http\Controllers\Api\ScadaController;
use App\Http\Controllers\SensorHistoryController;
use App\Http\Controllers\Api\ScadaActionController;
use App\Http\Controllers\Api\SocAlertController;


Route::get('/logs', [LogController::class, 'index'])
    ->middleware('throttle:logs-read');

Route::get('/health', function () {
    return response()->json(['status' => 'ok'], 200);
});


Route::prefix('machines')->group(function () {

    Route::get('/', [MachineController::class, 'index'])
        ->middleware('throttle:machines-read');

    Route::get('/{id}', [MachineController::class, 'show'])
        ->middleware('throttle:machines-read');

    Route::post('/{id}/start', [MachineController::class, 'start'])
        ->middleware('throttle:machines-control');

    Route::post('/{id}/stop', [MachineController::class, 'stop'])
        ->middleware('throttle:machines-control');
});


Route::prefix('scada')->group(function () {

    Route::get('/data', [ScadaController::class, 'index'])
        ->middleware('throttle:scada-read');

    Route::prefix('history')->group(function () {

        Route::get('/', [SensorHistoryController::class, 'index'])
            ->middleware('throttle:scada-read');

        Route::post('/', [SensorHistoryController::class, 'store'])
            ->middleware('throttle:scada-write');
    });

    Route::post('/action', [ScadaActionController::class, 'execute'])
        ->middleware('throttle:scada-write');
});



Route::prefix('soc')->group(function () {

    Route::post('/webhook', [SocAlertController::class, 'webhook'])
        ->middleware('throttle:soc-stream');

    Route::get('/alerts', [SocAlertController::class, 'index'])
        ->middleware('throttle:soc-stream');

    Route::get('/alerts/stats', [SocAlertController::class, 'stats'])
        ->middleware('throttle:logs-read');
});