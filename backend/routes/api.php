<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ApiController;

Route::post('/sessions/start', [ApiController::class, 'startSession']);
Route::get('/sessions/recover', [ApiController::class, 'recoverSession']);
Route::get('/menu', [ApiController::class, 'getMenu']);
Route::post('/activity', [ApiController::class, 'recordActivity']);
Route::get('/recommendations', [ApiController::class, 'getRecommendations']);
Route::post('/orders', [ApiController::class, 'submitOrder']);
Route::get('/orders', [ApiController::class, 'getOrderStatus']);
Route::post('/sessions/bill', [ApiController::class, 'requestBill']);

// Chef/Kitchen Routes
use App\Http\Controllers\ChefController;
Route::get('/chef/orders', [ChefController::class, 'getActiveOrders']);
Route::patch('/chef/orders/{id}', [ChefController::class, 'updateOrderStatus']);
