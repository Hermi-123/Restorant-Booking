<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ApiController;

Route::post('/sessions/start', [ApiController::class, 'startSession']);
Route::get('/sessions/recover', [ApiController::class, 'recoverSession']);
Route::get('/menu', [ApiController::class, 'getMenu']);
