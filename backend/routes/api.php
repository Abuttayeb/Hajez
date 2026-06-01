<?php
use Illuminate\Support\Facades\Artisan;

Route::get('/setup', function() {
    try {
        Artisan::call('migrate', ['--force' => true]);
        Artisan::call('db:seed', ['--force' => true]);
        return response()->json(['message' => 'Done! ✅', 'output' => Artisan::output()]);
    } catch (\Exception $e) {
        return response()->json(['error' => $e->getMessage()], 500);
    }
});
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\FarmController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\FcmController;

Route::post('/register',[AuthController::class,'register']);
Route::post('/login',[AuthController::class,'login']);
Route::get('/farms',[FarmController::class,'index']);
Route::get('/farms/{id}',[FarmController::class,'show']);
Route::get('/farms/{id}/availability',[FarmController::class,'availability']);
Route::get('/farms/{id}/reviews',[ReviewController::class,'farmReviews']);

Route::middleware('auth:sanctum')->group(function() {
    Route::post('/logout',[AuthController::class,'logout']);
    Route::get('/me',[AuthController::class,'me']);
    Route::post('/bookings',[BookingController::class,'store']);
    Route::get('/my-bookings',[BookingController::class,'myBookings']);
    Route::get('/my-bookings/{id}',[BookingController::class,'show']);
    Route::post('/my-bookings/{id}/cancel',[BookingController::class,'cancel']);
    Route::post('/reviews',[ReviewController::class,'store']);
    Route::post('/fcm-token', [FcmController::class, 'update']);

    Route::middleware('role:owner')->group(function() {
        Route::get('/my-farms',[FarmController::class,'myFarms']);
        Route::post('/farms',[FarmController::class,'store']);
        Route::put('/farms/{id}',[FarmController::class,'update']);
        Route::delete('/farms/{id}',[FarmController::class,'destroy']);
        Route::post('/farms/{id}/images',[FarmController::class,'uploadImage']);
        Route::get('/owner/bookings',[BookingController::class,'ownerBookings']);
        Route::put('/owner/bookings/{id}/status',[BookingController::class,'updateStatus']);
    });

    Route::middleware('role:admin')->prefix('admin')->group(function() {
        Route::get('/stats',[AdminController::class,'stats']);
        Route::get('/users',[AdminController::class,'getUsers']);
        Route::delete('/users/{id}',[AdminController::class,'deleteUser']);
        Route::put('/users/{id}/toggle',[AdminController::class,'toggleUser']);
        Route::get('/farms',[AdminController::class,'getFarms']);
        Route::put('/farms/{id}',[AdminController::class,'updateFarm']);
        Route::delete('/farms/{id}',[AdminController::class,'deleteFarm']);
        Route::get('/bookings',[AdminController::class,'getBookings']);
        Route::put('/bookings/{id}',[AdminController::class,'updateBooking']);
        Route::get('/reviews',[AdminController::class,'getReviews']);
        Route::delete('/reviews/{id}',[AdminController::class,'deleteReview']);
    });
});
