<?php

use Illuminate\Http\Request;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\UserGeneralController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:api')->group(function () {
    Route::get('/user', [AuthController::class, 'profile']);
    Route::post('/general', [GeneralController::class, 'store']);
});
Route::post('/logout', [AuthController::class, 'logout']);
Route::post('/user_general', [UserGeneralController::class, 'store']);

Route::post('/send-otp', [OtpController::class, 'sendOtp']);
Route::post('/verify-otp', [OtpController::class, 'verifyOtp']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/messages', [MessageController::class, 'store']); // send
    Route::get('/messages/{receiverId}', [MessageController::class, 'conversation']); // fetch
});