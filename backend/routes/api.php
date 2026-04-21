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

// Admin Management Routes
use App\Http\Controllers\AdminController;
Route::get('/admin/tables', [AdminController::class, 'getTables']);
Route::post('/admin/tables', [AdminController::class, 'addTable']);
Route::get('/admin/categories', [AdminController::class, 'getCategories']);
Route::post('/admin/categories', [AdminController::class, 'addCategory']);
Route::post('/admin/menu-items', [AdminController::class, 'addMenuItem']);
Route::patch('/admin/menu-items/{id}/availability', [AdminController::class, 'updateMenuItemAvailability']);
